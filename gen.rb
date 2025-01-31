require 'find'
require 'redcarpet'
require 'pathname'

class Renderer < Redcarpet::Render::HTML
end

markdown = Redcarpet::Markdown.new(Renderer.new, extensions = {})


src_dir = Pathname('src')
build_dir = Pathname('build')

Find.find('src') do |path|
  next if File.directory?(path)
  next if path =~ /~$/

  path = Pathname(path)
  html_path = build_dir + path.relative_path_from(src_dir)

  d = html_path.dirname
  d.mkpath unless d.exist?

  File.open(html_path.to_s.gsub(/\.md$/, '.html'), 'w') do |f|
    f.write(markdown.render(File.read(path)))
  end
end
