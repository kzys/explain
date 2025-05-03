require 'find'
require 'markly'
require 'pathname'
require 'erb'
require 'yaml'
require 'open3'
require 'time'

class Page
  def initialize
    @title = nil
    @content = nil
    @url = nil
    @draft = false
    @ctime = nil
    @mtime = nil
  end

  attr_accessor :title
  attr_accessor :content
  attr_accessor :url
  attr_accessor :draft
  attr_accessor :ctime, :mtime
    
  
  def self.find(pattern)
    g = Gen.new
    Dir.glob(pattern).map do |path|
      g.parse_file(path)
    end.delete_if do |page|
      page and page.draft
    end.sort_by {|p| p.ctime.to_s }.reverse
  end
end

class Gen
  def initialize
    @src_dir = Pathname('src')
    @file_to_time = parse_git_log
  end

  def parse_git_log
    ret = {}
    
    stdin, stdout, stderr, wait_thr = Open3.popen3('git', 'log', '--name-only', "--format=format:\t%aI")
    stdin.close
    stdout.read.split(/\t/).each do |commit|
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
    
    doc = Markly.parse(md)
    unless result.title
      doc.walk do |node|
        if node.type == :header and node.header_level == 1
          result.title = node.first_child.string_content
        end
      end
    end

    result.content = doc.to_html

    url = Pathname(path).relative_path_from(@src_dir).to_s
    url.gsub!(/\.md$/, '.html')
    result.url = url

    if times = @file_to_time[path]
      result.ctime = times[-1]
      result.mtime = times[0]
    end

    result
  end
  
  def run
    src_dir = Pathname('src')
    public_dir = Pathname('public')

    layout = ERB.new(Pathname('view').join('layout.html.erb').read)

    Find.find('src') do |path|
      next if File.directory?(path)
      next if path =~ /~$/

      path = Pathname(path)
      html_path = public_dir + path.relative_path_from(src_dir)

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
        dest = public_dir + path.relative_path_from(src_dir)

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
end

Gen.new.run if __FILE__ == $0
