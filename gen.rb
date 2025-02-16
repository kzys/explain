require 'find'
require 'redcarpet'
require 'pathname'
require 'erb'

class Renderer < Redcarpet::Render::HTML
end

markdown = Redcarpet::Markdown.new(Renderer.new, extensions = {})


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
      content = markdown.render(File.read(path))
      title = ""

      h = layout.result(binding)
      f.write(h)
    end
  else
    File.open(html_path, 'w') do |f|
      f.write(File.read(path))
    end
  end
end
