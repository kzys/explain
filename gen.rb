require 'find'
require 'markly'
require 'pathname'
require 'erb'
require 'yaml'
require 'open3'
require 'time'
require 'yaml'

class Page
  def initialize
    @title = nil
    @content = nil
    @url = nil
    @draft = false
    @ctime = nil
    @mtime = nil
    @size = nil
  end

  attr_accessor :title
  attr_accessor :content
  attr_accessor :url
  attr_accessor :draft
  attr_accessor :ctime, :mtime
  attr_accessor :size
end

class Gen
  def initialize(src_dir, dest_dir, config = {})
    @src_dir = Pathname(src_dir)
    @dest_dir = Pathname(dest_dir)
    @config = config

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
    result.content = Markly.parse(md).to_html

    url = Pathname(path).relative_path_from(@src_dir).to_s
    url.gsub!(/\.md$/, '.html')
    result.url = url

    if times = @file_to_time[path]
      result.ctime = times[-1]
      result.mtime = times[0]
    else
      result.ctime = File.ctime(path)
      result.mtime = File.mtime(path)
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

  def run
    layout = ERB.new(Pathname('view').join('layout.html.erb').read)

    Find.find(@src_dir.to_s) do |path|
      next if File.directory?(path)
      next if path =~ /~$/

      path = Pathname(path)
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
      else
        File.open(html_path, 'w') do |f|
          f.write(File.read(path))
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
end

config = YAML.load_file('config.yaml')
Gen.new('src', 'public', config).run if __FILE__ == $0
