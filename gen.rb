require 'find'
require 'markly'
require 'pathname'
require 'erb'
require 'yaml'

ViewModel = Struct.new(:title, :content)

class Gen
  def parse_file(path)
    result = ViewModel.new

    md = nil
    raw = File.read(path)
    if raw =~ /\A---/
      docs = raw.split(/^---$/, 3)
      front_matter = YAML.load(docs[1])
      result.title = front_matter['title']
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

    result
  end
  
  def run
    src_dir = Pathname('src')
    public_dir = Pathname('public')

    layout = ERB.new(src_dir.join('layout.html.erb').read)

    Find.find('src') do |path|
      next if File.directory?(path)
      next if path =~ /~$/

      path = Pathname(path)
      html_path = public_dir + path.relative_path_from(src_dir)

      d = html_path.dirname
      d.mkpath unless d.exist?

      if path.extname == '.md'
        File.open(html_path.to_s.gsub(/\.md$/, '.html'), 'w') do |f|
          begin
            page = self.parse_file(path)
            h = layout.result(binding)
            f.write(h)
          rescue => e
            STDERR.puts("failed to process #{f}: #{e}")
          end
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
