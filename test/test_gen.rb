require 'simplecov'
SimpleCov.minimum_coverage 80
SimpleCov.start

require 'minitest/autorun'
require_relative '../gen'

class TestSizeFormatter < Minitest::Test
  def test_bytes
    assert_equal('512 bytes', SizeFormatter.human_size(512))
    assert_equal('1023 bytes', SizeFormatter.human_size(1023))
  end

  def test_kibibytes
    assert_equal('1.0 KiB', SizeFormatter.human_size(1024))
    assert_equal('1.5 KiB', SizeFormatter.human_size(1536))
    assert_equal('10.2 KiB', SizeFormatter.human_size(10445))
  end
end

class TestPage < Minitest::Test
  def page(url)
    Page.new.tap { |p| p.url = url }
  end

  def test_japanese_page
    page = page('ja/test.html')
    assert_equal('ja', page.language)
    assert(page.ja?)
    refute(page.en?)
    assert_equal('日本語', page.language_name)
    assert_equal('ja-bar', page.bar_class)
  end

  def test_english_page
    page = page('en/test.html')
    assert_equal('en', page.language)
    refute(page.ja?)
    assert(page.en?)
    assert_equal('English', page.language_name)
    assert_equal('en-bar', page.bar_class)
  end

  def test_directory
    {
      'ja/music/tricot.html' => 'music',
      'ja/foo/bar/baz.html' => 'foo/bar',
      'en/homelab/server.html' => 'homelab',
      'en/linux/tutorials/setup.html' => 'linux/tutorials',
    }.each do |url, expected|
      assert_equal(expected, page(url).directory, url)
    end
    assert_nil(page('ja/tricot.html').directory)
    assert_nil(page('en/about.html').directory)
  end

  def test_human_size
    assert_equal('512 bytes', Page.new.tap { |p| p.size = 512 }.human_size)
  end
end

class TestGen < Minitest::Test
  def setup
    @gen = Gen.new(Pathname('testdata/src'), Dir.mktmpdir)
  end

  def test_front_matter
    page = @gen.parse_file('test/front_matter.md')
    assert_equal('from front matter', page.title)
    assert_match(/hello world/, page.content)
    assert_equal(true, page.draft)
  end

  def test_markdown
    page = @gen.parse_file('test/markdown.md')
    assert_equal('h1', page.title)
    assert_equal(<<END, page.content)
<p>foo</p>
<hr />
<p>bar</p>
END
  end

  def test_h1_title_extraction
    page = @gen.parse_file('test/h1_title.md')
    assert_equal('My H1 Title', page.title)
    # H1 is rendered separately in the layout, not in content
    refute_match(%r{<h1>My H1 Title</h1>}, page.content)
    assert_equal(false, page.draft)
  end

  def test_no_title
    page = @gen.parse_file('test/no_title.md')
    assert_nil(page.title)
    assert_match(/This is a markdown file/, page.content)
    assert_equal(false, page.draft)
  end

  def test_url_generation
    page = @gen.parse_file('test/markdown.md')
    assert_equal('../../test/markdown.html', page.url)
  end

  def test_timestamps
    page = @gen.parse_file('test/markdown.md')
    assert_instance_of(Time, page.ctime)
    assert_instance_of(Time, page.mtime)
  end

  def test_parse_git_log
    log = File.read('testdata/git_log.txt')
    assert(@gen.parse_git_log(log))
  end

  def test_simple_rename
    out = "R100\tsrc/ja/customers.md\tsrc/ja/customer.md\n"
    renames = @gen.parse_git_renames(out)
    assert_equal('src/ja/customer.md', renames['src/ja/customers.md'])
  end

  def test_transitive_rename
    out = "R100\tsrc/ja/b.md\tsrc/ja/c.md\nR100\tsrc/ja/a.md\tsrc/ja/b.md\n"
    renames = @gen.parse_git_renames(out)
    assert_equal('src/ja/c.md', renames['src/ja/a.md'])
    assert_equal('src/ja/c.md', renames['src/ja/b.md'])
  end

  def test_rename_parsing_edge_cases
    assert_equal({}, @gen.parse_git_renames(''))

    renames = @gen.parse_git_renames("\nR100\tsrc/ja/customers.md\tsrc/ja/customer.md\n\n")
    assert_equal({ 'src/ja/customers.md' => 'src/ja/customer.md' }, renames)
  end

  def test_site_root
    { 'index.html' => '.', 'en/about.html' => '..', 'en/blog/post.html' => '../..' }.each do |url, expected|
      assert_equal(expected, @gen.site_root(Page.new.tap { |p| p.url = url }), url)
    end
  end

  def test_file_hash
    assert_match(/^[0-9a-f]{8}$/, @gen.file_hash('test content'))
  end

  def test_asset_path
    @gen.instance_variable_get(:@asset_hashes)['style.css'] = 'style-abc123.css'
    assert_equal('style-abc123.css', @gen.asset_path('style.css'))
    assert_equal('unknown.css', @gen.asset_path('unknown.css'))
  end

  def test_group_by_content
    grouped = @gen.group_by_content(@gen.find('test/*.md'))
    assert_kind_of(Hash, grouped)
  end

  def test_run
    @gen.run
  end

  def test_include_does_not_clobber_surrounding_output
    gen = @gen
    template = ERB.new("before<%= gen.include('footer.html.erb', binding) %>after")
    result = template.result(binding)
    assert_includes(result, 'before')
    assert_includes(result, 'after')
  end
end

class TestMarkdownParsing < Minitest::Test
  def setup
    tmpdir = Dir.mktmpdir
    @src_dir = File.join(tmpdir, 'src')
    Dir.mkdir(@src_dir)
    @gen = Gen.new(@src_dir, File.join(tmpdir, 'public'))
  end

  def parse(md)
    path = File.join(@src_dir, 'test.md')
    File.write(path, md)
    @gen.parse_file(path)
  end

  def test_relative_md_links_rewritten_to_html
    {
      './other.md' => './other.html',
      'other.md' => 'other.html',
      '../other.md' => '../other.html',
      './other.html' => './other.html',
    }.each do |link, expected|
      page = parse("# Title\n[link](#{link})")
      assert_match(%r{href="#{Regexp.escape(expected)}"}, page.content, link)
    end
  end

  def test_absolute_links_not_rewritten
    [
      'http://example.com/file.md',
      'https://example.com/file.md',
      '//example.com/file.md',
    ].each do |link|
      page = parse("# Title\n[link](#{link})")
      assert_match(%r{href="#{Regexp.escape(link)}"}, page.content, link)
    end
  end

  def test_first_h1_becomes_title_not_headline
    page = parse("# Hello World")
    assert_equal('Hello World', page.title)
    assert_equal([], page.headlines)
  end

  def test_multiple_headlines
    page = parse(<<~MD)
      # Main Title
      Some content here.
      ## Section One
      More content.
      ### Subsection
      ## Section Two
    MD
    assert_equal('Main Title', page.title)
    assert_equal([
      { level: 2, text: 'Section One' },
      { level: 3, text: 'Subsection' },
      { level: 2, text: 'Section Two' },
    ], page.headlines)
  end

  def test_headline_with_inline_formatting
    {
      "## Section **with bold**" => 'Section with bold',
      "## Section *with italic*" => 'Section with italic',
      "## Section [with link](http://example.com)" => 'Section with link',
    }.each do |md, text|
      assert_equal([{ level: 2, text: text }], parse(md).headlines, md)
    end
  end

  def test_no_headlines
    page = parse("Just some plain text\nwithout any headlines.")
    assert_equal([], page.headlines)
  end

  def test_all_heading_levels
    page = parse((1..6).map { |level| "#{'#' * level} H#{level}" }.join("\n"))
    assert_equal('H1', page.title)
    assert_equal((2..6).map { |level| { level: level, text: "H#{level}" } }, page.headlines)
  end

  def test_second_h1_stays_as_headline
    page = parse("# Title\n# Another")
    assert_equal('Title', page.title)
    assert_equal([{ level: 1, text: 'Another' }], page.headlines)
  end

  def test_h1_inside_code_block_is_left_alone
    page = parse("---\ntitle: front\n---\n```\n# comment\n```")
    assert_equal('front', page.title)
    assert_match(/# comment/, page.content)
    assert_equal([], page.headlines)
  end
end

class TestGenerateRedirects < Minitest::Test
  def setup
    tmpdir = Pathname(Dir.mktmpdir)
    @src_dir = tmpdir + 'src'
    @dest_dir = tmpdir + 'public'
    @src_dir.mkpath
    @dest_dir.mkpath
    @gen = Gen.new(@src_dir, @dest_dir)
  end

  def create_src(name)
    path = @src_dir + name
    path.dirname.mkpath
    path.write("# Title\nhello")
    path
  end

  def test_generates_redirect_html
    new_path = create_src('customer.md')
    old_str = (@src_dir + 'customers.md').to_s

    @gen.generate_redirects({ old_str => new_path.to_s }, [new_path])

    content = File.read(@dest_dir + 'customers.html')
    assert_match(/<meta http-equiv="refresh"/, content)
    assert_match(/<link rel="canonical"/, content)
    assert_match(%r{/customer\.html}, content)
  end

  def test_no_redirect_when_old_file_still_exists
    old_path = create_src('customers.md')
    new_path = create_src('customer.md')

    @gen.generate_redirects(
      { old_path.to_s => new_path.to_s },
      [old_path, new_path]
    )

    refute File.exist?(@dest_dir + 'customers.html')
  end

  def test_no_redirect_when_destination_missing
    old_str = (@src_dir + 'old.md').to_s
    new_str = (@src_dir + 'new.md').to_s

    @gen.generate_redirects({ old_str => new_str }, [])

    refute File.exist?(@dest_dir + 'old.html')
  end

  def test_subdirectory_redirect
    new_path = create_src('music/new.md')
    old_str = (@src_dir + 'music/old.md').to_s

    @gen.generate_redirects({ old_str => new_path.to_s }, [new_path])

    content = File.read(@dest_dir + 'music/old.html')
    assert_match(%r{/music/new\.html}, content)
  end
end
