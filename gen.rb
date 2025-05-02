require 'find'
require 'markly'
require 'pathname'
require 'erb'

src_dir = Pathname('src')
build_dir = Pathname('build')

layout = ERB.new(src_dir.join('layout.html.erb').read)

Find.find('src') do |path|
  next if File.directory?(path)
  next if path =~ /~$/

  path = Pathname(path)
  html_path = build_dir + path.relative_path_from(src_dir)

  d = html_path.dirname
  d.mkpath unless d.exist?

  if path.extname == '.md'
    File.open(html_path.to_s.gsub(/\.md$/, '.html'), 'w') do |f|
      doc = Markly.parse(File.read(path))
      title = nil
      doc.walk do |node|
        if node.type == :header and node.header_level == 1
          title = node.first_child.string_content
        end
      end
      content = doc.to_html
      h = layout.result(binding)
      f.write(h)
    end
  else
    File.open(html_path, 'w') do |f|
      f.write(File.read(path))
    end
  end
end
