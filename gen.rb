require 'find'
require 'markly'
require 'pathname'
require 'erb'
require 'yaml'
require 'open3'
require 'time'
require 'yaml'
require 'digest'

module SizeFormatter
  def self.human_size(size)
    kb = size / 1024.0
    if kb < 1
      "#{size} bytes"
    else
      "#{kb.round(1)} KiB"
    end
  end
end

class Page
  def initialize
    @title = nil
    @content = nil
    @url = nil
    @draft = false
    @changes = []
    @size = nil
  end

  attr_accessor :title
  attr_accessor :content
  attr_accessor :url
  attr_accessor :draft
  attr_accessor :changes
  attr_accessor :size

  # Convenience methods for backward compatibility
  def ctime
    @changes.last
  end

  def mtime
    @changes.first
  end

  # Language detection methods
  def language
    @url =~ %r{^ja/} ? 'ja' : 'en'
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

  def language_class
    ja? ? 'lang-ja' : 'lang-en'
  end

  def bar_class
    ja? ? 'ja-bar' : 'en-bar'
  end

  def human_size
    SizeFormatter.human_size(@size)
  end
end

class Gen
  def initialize(src_dir, dest_dir, config = {})
    @src_dir = Pathname(src_dir)
    @dest_dir = Pathname(dest_dir)
    @config = config
    @asset_hashes = {}

    stdin, stdout, stderr, wait_thr = Open3.popen3('git', 'log', '--name-only', "--format=format:\t%aI")
    stdin.close
    @file_to_time = parse_git_log(stdout.read)
  end

  def parse_git_log(out)
    ret = {}

    out.split(/\t/).each do |commit|
      xs = commit.split(/\n/)
      date = xs.shift
      xs.each do |path|
        ret[path] = (ret[path] || []) + [Time.parse(date)]
      end
    end

    ret
  end

  def parse_file(path)
    result = Page.new

    md = nil
    raw = File.read(path)
    if raw =~ /\A---/
      docs = raw.split(/^---$/, 3)
      front_matter = YAML.load(docs[1])
      result.title = front_matter['title']
      result.draft = front_matter['draft']
      md = docs[2]
    else
      md = raw
    end

    # Parse to extract title if needed
    doc = Markly.parse(md)
    unless result.title
      doc.walk do |node|
        if node.type == :header and node.header_level == 1
          result.title = node.first_child.string_content
          break
        end
      end
    end

    # Remove h1 from markdown and re-parse for content (we'll render title separately)
    md = md.sub(/^#\s+.*$\n?/, '')
    result.content = Markly.parse(md, flags: Markly::UNSAFE).to_html(flags: Markly::UNSAFE)

    url = Pathname(path).relative_path_from(@src_dir).to_s
    url.gsub!(/\.md$/, '.html')
    result.url = url

    # Convert path to string for lookup in @file_to_time (which uses string keys)
    path_str = path.is_a?(Pathname) ? path.to_s : path
    if times = @file_to_time[path_str]
      result.changes = times
    else
      # If not in git, use file system times
      result.changes = [File.mtime(path)]
    end
    result.size = File.size(path)

    result
  end

  def include(path)
    ERB.new(Pathname('view').join(path).read).result(binding)
  end

  def site_root(page)
    # Calculate relative path back to root based on current page's URL depth
    depth = page.url.count('/')
    if depth == 0
      "."
    else
      ("../" * depth).chomp("/")
    end
  end

  def file_hash(content)
    # Generate a short hash (first 8 chars of SHA256) for cache busting
    Digest::SHA256.hexdigest(content)[0...8]
  end

  def asset_path(filename)
    # Return the hashed version of the asset filename if it exists
    @asset_hashes[filename] || filename
  end

  def human_size(size)
    SizeFormatter.human_size(size)
  end

  def run
    layout = ERB.new(Pathname('view').join('layout.html.erb').read)

    # Collect all files to process
    files_to_process = []
    Find.find(@src_dir.to_s) do |path|
      next if File.directory?(path)
      next if path =~ /~$/
      next if File.basename(path) =~ /^\.#/
      files_to_process << Pathname(path)
    end

    # First pass: process static assets to build hash mappings
    cachebust_exts = ['.css', '.js', '.ico', '.svg', '.woff', '.woff2', '.ttf', '.eot']

    files_to_process.each do |path|
      next if ['.md', '.erb'].include?(path.extname)

      html_path = @dest_dir + path.relative_path_from(@src_dir)
      d = html_path.dirname
      d.mkpath unless d.exist?

      content = File.read(path)

      if cachebust_exts.include?(path.extname)
        # Calculate hash and generate new filename
        hash = file_hash(content)
        basename = path.basename(path.extname).to_s
        extname = path.extname
        hashed_filename = "#{basename}-#{hash}#{extname}"

        # Store mapping of original filename -> hashed filename
        original_filename = path.basename.to_s
        @asset_hashes[original_filename] = hashed_filename

        # Write file with hashed name
        hashed_path = html_path.dirname + hashed_filename
        File.open(hashed_path, 'w') do |f|
          f.write(content)
        end
      else
        # Copy other files as-is
        File.open(html_path, 'w') do |f|
          f.write(content)
        end
      end
    end

    # Second pass: process markdown and ERB files that can reference hashed assets
    files_to_process.each do |path|
      html_path = @dest_dir + path.relative_path_from(@src_dir)

      d = html_path.dirname
      d.mkpath unless d.exist?

      case path.extname
      when '.md'
        File.open(html_path.to_s.gsub(/\.md$/, '.html'), 'w') do |f|
          begin
            page = self.parse_file(path)
            h = layout.result(binding)
            f.write(h)
          rescue => e
            STDERR.puts("failed to process #{f}: #{e}")
          end
        end
      when '.erb'
        dest = @dest_dir + path.relative_path_from(@src_dir)
        File.open(dest.to_s.gsub(/\.erb$/, ''), 'w') do |f|
          f.write(ERB.new(path.read).result(binding))
        end
      end
    end
  end

  def find(pattern)
    Dir.glob(pattern).map do |path|
      parse_file(path)
    end.delete_if do |page|
      page and page.draft
    end.sort_by {|p| p.ctime.to_s }.reverse
  end

  def group_by_content(pages)
    # Group pages by their base path (without language prefix)
    groups = {}

    pages.each do |page|
      # Extract base path without language prefix (en/ or ja/)
      base_path = page.url.sub(%r{^(en|ja)/}, '')

      groups[base_path] ||= []
      groups[base_path] << page
    end

    # Sort each group by language (en first, then ja)
    groups.each do |base_path, group_pages|
      groups[base_path] = group_pages.sort_by do |p|
        p.url =~ %r{^en/} ? 0 : 1
      end
    end

    # Sort groups by most recent modification time
    groups.sort_by do |base_path, group_pages|
      group_pages.map(&:mtime).max
    end.reverse.to_h
  end
end

config = YAML.load_file('config.yaml')
Gen.new('src', 'public', config).run if __FILE__ == $0
