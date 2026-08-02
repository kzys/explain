require 'find'
require 'markly'
require 'pathname'
require 'erb'
require 'yaml'
require 'open3'
require 'set'
require 'time'
require 'digest'

module SizeFormatter
  def self.human_size(size)
    size < 1024 ? "#{size} bytes" : "#{(size / 1024.0).round(1)} KiB"
  end
end

Page = Struct.new(:title, :content, :url, :draft, :changes, :size, :headlines) do
  def ctime
    changes.last
  end

  def mtime
    changes.first
  end

  def language
    url.start_with?('ja/') ? 'ja' : 'en'
  end

  def ja?
    language == 'ja'
  end

  def en?
    language == 'en'
  end

  def language_name
    ja? ? '日本語' : 'English'
  end

  def bar_class
    ja? ? 'ja-bar' : 'en-bar'
  end

  def human_size
    SizeFormatter.human_size(size)
  end

  # "ja/music/tricot.html" -> "music", "ja/tricot.html" -> nil
  def directory
    parts = url.sub(%r{^(en|ja)/}, '').split('/')
    parts.length > 1 ? parts[0..-2].join('/') : nil
  end
end

class Gen
  CACHEBUST_EXTS = %w[.css .js .ico .svg .woff .woff2 .ttf .eot]

  def initialize(src_dir, dest_dir, config = {})
    @src_dir = Pathname(src_dir)
    @dest_dir = Pathname(dest_dir)
    @config = config
    @asset_hashes = {}

    log_out, = Open3.capture2('git', 'log', '--name-only', "--format=format:\t%aI")
    @file_to_time = parse_git_log(log_out)

    rename_out, = Open3.capture2('git', 'log', '--diff-filter=R', '--name-status', '--format=')
    @renames = parse_git_renames(rename_out)

    status_out, = Open3.capture2('git', 'status', '--porcelain')
    @dirty_files = status_out.lines.map { |l| l[3..].chomp }.to_set
  end

  def parse_git_log(out)
    ret = {}
    out.split(/\t/).each do |commit|
      date, *paths = commit.split(/\n/)
      paths.each { |path| (ret[path] ||= []) << Time.parse(date) }
    end
    ret
  end

  def parse_git_renames(out)
    renames = out.scan(/^R\d+\t(.+)\t(.+)$/).to_h
    # Resolve chains (a -> b, b -> c becomes a -> c), guarding against cycles
    renames.each_key do |old|
      cur = old
      seen = Set[cur]
      cur = renames[cur] while renames.key?(cur) && seen.add?(renames[cur])
      renames[old] = cur
    end
    renames
  end

  def parse_file(path)
    path = path.to_s
    page = Page.new
    page.draft = false
    page.headlines = []

    md = File.read(path)
    if md =~ /\A---/
      _, front_matter, md = md.split(/^---$/, 3)
      meta = YAML.load(front_matter)
      page.title = meta['title']
      page.draft = meta['draft']
    end

    doc = Markly.parse(md, flags: Markly::UNSAFE)
    h1 = nil
    doc.walk do |node|
      case node.type
      when :header
        if h1.nil? && node.header_level == 1
          h1 = node
        else
          page.headlines << { level: node.header_level, text: collect_text(node) }
        end
      when :link
        if node.url.end_with?('.md') && !node.url.match?(%r{^(\w+:)?//})
          node.url = node.url.sub(/\.md$/, '.html')
        end
      end
    end
    if h1
      page.title ||= collect_text(h1)
      h1.delete # the title is rendered separately by the layout
    end
    page.content = doc.to_html(flags: Markly::UNSAFE)

    page.url = Pathname(path).relative_path_from(@src_dir).to_s.sub(/\.md$/, '.html')
    page.changes = @file_to_time[path] || [File.mtime(path)]
    page.changes = [File.mtime(path)] + page.changes if @dirty_files.include?(path)
    page.size = File.size(path)
    page
  end

  def collect_text(node)
    text = ''
    node.each do |child|
      text += child.type == :text ? child.string_content : collect_text(child)
    end
    text
  end

  def include(path, b = binding)
    eoutvar = "_erbout_#{path.gsub(/\W/, '_')}"
    ERB.new(Pathname('view').join(path).read, trim_mode: nil, eoutvar: eoutvar).result(b)
  end

  def site_root(page)
    depth = page.url.count('/')
    depth == 0 ? '.' : ('../' * depth).chomp('/')
  end

  def file_hash(content)
    Digest::SHA256.hexdigest(content)[0...8]
  end

  def asset_path(filename)
    @asset_hashes[filename] || filename
  end

  def human_size(size)
    SizeFormatter.human_size(size)
  end

  def run
    layout = ERB.new(Pathname('view').join('layout.html.erb').read)

    sources = []
    Find.find(@src_dir.to_s) do |found|
      next if File.directory?(found) || found.end_with?('~') || File.basename(found).start_with?('.#')
      sources << Pathname(found)
    end
    templates, assets = sources.partition { |src| ['.md', '.erb'].include?(src.extname) }

    # Assets go first so that templates can reference the hashed filenames
    assets.each { |src| copy_asset(src) }
    templates.each do |src|
      dest = dest_path(src)
      if src.extname == '.md'
        render_markdown(src, dest.sub_ext('.html'), layout)
      else
        File.write(dest.sub_ext(''), ERB.new(src.read).result(binding))
      end
    end

    generate_redirects(@renames, sources)
  end

  def dest_path(src)
    dest = @dest_dir + src.relative_path_from(@src_dir)
    dest.dirname.mkpath
    dest
  end

  def copy_asset(src)
    dest = dest_path(src)
    content = File.read(src)
    if CACHEBUST_EXTS.include?(src.extname)
      hashed = "#{src.basename(src.extname)}-#{file_hash(content)}#{src.extname}"
      @asset_hashes[src.basename.to_s] = hashed
      dest = dest.dirname + hashed
    end
    File.write(dest, content)
  end

  def render_markdown(src, dest, layout)
    page = parse_file(src)
    File.write(dest, layout.result(binding))
  rescue => e
    STDERR.puts("failed to process #{src}: #{e}")
  end

  def generate_redirects(renames, existing_src_paths)
    template = ERB.new(Pathname('view').join('redirect.html.erb').read)
    existing = existing_src_paths.map(&:to_s).to_set

    renames.each do |old_src, new_src|
      next unless old_src.end_with?('.md')
      next if existing.include?(old_src) || !existing.include?(new_src)

      old_url = Pathname(old_src).relative_path_from(@src_dir).to_s.sub(/\.md$/, '.html')
      dest_abs = '/' + Pathname(new_src).relative_path_from(@src_dir).to_s.sub(/\.md$/, '.html')

      out_path = @dest_dir + old_url
      out_path.dirname.mkpath
      File.write(out_path, template.result(binding))
    end
  end

  def find(pattern)
    pages = Dir.glob(pattern).map { |path| parse_file(path) }
    pages.reject(&:draft).sort_by { |page| page.ctime.to_s }.reverse
  end

  def group_by_content(pages)
    groups = pages.group_by { |page| page.url.sub(%r{^(en|ja)/}, '') }
    groups.each_value { |group| group.sort_by! { |page| page.ja? ? 1 : 0 } }
    groups.sort_by { |_, group| group.map(&:mtime).max }.reverse.to_h
  end
end

config = YAML.load_file('config.yaml')
Gen.new('src', 'public', config).run if __FILE__ == $0
