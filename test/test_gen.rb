require 'simplecov'
SimpleCov.minimum_coverage 80
SimpleCov.start

require 'minitest/autorun'
require_relative '../gen'

class TestGen < Minitest::Test
  def setup
    dir = Dir.mktmpdir
    @gen = Gen.new(Pathname('testdata/src'), dir)
  end

  def test_front_matter
    vm = @gen.parse_file('test/front_matter.md')
    assert_equal('from front matter', vm.title)
    assert_match(/hello world/, vm.content)
    assert_equal(true, vm.draft)
  end

  def test_markdown
    vm = @gen.parse_file('test/markdown.md')
    assert_equal('h1', vm.title)
    assert_equal(<<END, vm.content)
<p>foo</p>
<hr />
<p>bar</p>
END

  end

  def test_h1_title_extraction
    vm = @gen.parse_file('test/h1_title.md')
    assert_equal('My H1 Title', vm.title)
    # H1 is now rendered separately in the layout, not in content
    refute_match(%r{<h1>My H1 Title</h1>}, vm.content)
    assert_equal(false, vm.draft)
  end

  def test_no_title
    vm = @gen.parse_file('test/no_title.md')
    assert_nil(vm.title)
    assert_match(/This is a markdown file/, vm.content)
    assert_equal(false, vm.draft)
  end

  def test_url_generation
    vm = @gen.parse_file('test/markdown.md')
    assert_equal('../../test/markdown.html', vm.url)
  end

  def test_timestamps
    vm = @gen.parse_file('test/markdown.md')
    assert_instance_of(Time, vm.ctime)
    assert_instance_of(Time, vm.mtime)
  end

  def test_parse_git_log
    log = File.read('testdata/git_log.txt')
    file_to_time = @gen.parse_git_log(log)
    assert(file_to_time)
  end

  def test_run
    @gen.run
  end
end

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

class TestPageHumanSize < Minitest::Test
  def setup
    dir = Dir.mktmpdir
    @gen = Gen.new(Pathname('testdata/src'), dir)
  end

  def test_page_human_size
    vm = @gen.parse_file('test/markdown.md')
    # Verify that the human_size method works on Page instances
    assert_match(/bytes|KiB/, vm.human_size)
  end
end

class TestPageLanguageMethods < Minitest::Test
  def setup
    dir = Dir.mktmpdir
    @gen = Gen.new(Pathname('testdata/src'), dir)
  end

  def test_japanese_page_language_methods
    # Create a Japanese page by setting url to start with ja/
    page = @gen.parse_file('test/markdown.md')
    page.url = 'ja/test.html'

    assert_equal('ja', page.language)
    assert_equal(true, page.ja?)
    assert_equal(false, page.en?)
    assert_equal('日本語', page.language_name)
    assert_equal('lang-ja', page.language_class)
    assert_equal('ja-bar', page.bar_class)
  end

  def test_english_page_language_methods
    # Create an English page by setting url to start with en/
    page = @gen.parse_file('test/markdown.md')
    page.url = 'en/test.html'

    assert_equal('en', page.language)
    assert_equal(false, page.ja?)
    assert_equal(true, page.en?)
    assert_equal('English', page.language_name)
    assert_equal('lang-en', page.language_class)
    assert_equal('en-bar', page.bar_class)
  end
end

class TestGenHelperMethods < Minitest::Test
  def setup
    dir = Dir.mktmpdir
    @gen = Gen.new(Pathname('testdata/src'), dir)
  end

  def test_site_root_depth_zero
    page = @gen.parse_file('test/markdown.md')
    page.url = 'index.html'
    assert_equal('.', @gen.site_root(page))
  end

  def test_site_root_depth_one
    page = @gen.parse_file('test/markdown.md')
    page.url = 'en/about.html'
    assert_equal('..', @gen.site_root(page))
  end

  def test_site_root_depth_two
    page = @gen.parse_file('test/markdown.md')
    page.url = 'en/blog/post.html'
    assert_equal('../..', @gen.site_root(page))
  end

  def test_file_hash
    content = 'test content'
    hash = @gen.file_hash(content)
    assert_equal(8, hash.length)
    assert_match(/^[0-9a-f]{8}$/, hash)
  end

  def test_asset_path_with_hash
    @gen.instance_variable_get(:@asset_hashes)['style.css'] = 'style-abc123.css'
    assert_equal('style-abc123.css', @gen.asset_path('style.css'))
  end

  def test_asset_path_without_hash
    assert_equal('unknown.css', @gen.asset_path('unknown.css'))
  end
end

class TestGroupByContent < Minitest::Test
  def setup
    dir = Dir.mktmpdir
    @gen = Gen.new(Pathname('testdata/src'), dir)
  end

  def test_group_by_content
    pages = @gen.find('test/*.md')
    grouped = @gen.group_by_content(pages)
    assert_kind_of(Hash, grouped)
  end
end

class TestPageDirectory < Minitest::Test
  def setup
    dir = Dir.mktmpdir
    @gen = Gen.new(Pathname('testdata/src'), dir)
  end

  def test_directory_with_single_level
    # ja/music/tricot.html -> "music"
    page = @gen.parse_file('test/markdown.md')
    page.url = 'ja/music/tricot.html'
    assert_equal('music', page.directory)
  end

  def test_directory_with_nested_levels
    # ja/foo/bar/baz.html -> "foo/bar"
    page = @gen.parse_file('test/markdown.md')
    page.url = 'ja/foo/bar/baz.html'
    assert_equal('foo/bar', page.directory)
  end

  def test_directory_in_root
    # ja/tricot.html -> nil
    page = @gen.parse_file('test/markdown.md')
    page.url = 'ja/tricot.html'
    assert_nil(page.directory)
  end

  def test_directory_english_page
    # en/homelab/server.html -> "homelab"
    page = @gen.parse_file('test/markdown.md')
    page.url = 'en/homelab/server.html'
    assert_equal('homelab', page.directory)
  end

  def test_directory_english_nested
    # en/linux/tutorials/setup.html -> "linux/tutorials"
    page = @gen.parse_file('test/markdown.md')
    page.url = 'en/linux/tutorials/setup.html'
    assert_equal('linux/tutorials', page.directory)
  end

  def test_directory_english_root
    # en/about.html -> nil
    page = @gen.parse_file('test/markdown.md')
    page.url = 'en/about.html'
    assert_nil(page.directory)
  end
end

class TestExtractHeadlines < Minitest::Test
  def setup
    dir = Dir.mktmpdir
    @gen = Gen.new(Pathname('testdata/src'), dir)
  end

  def test_single_headline
    md = "# Hello World"
    headlines = @gen.extract_headlines(md)
    assert_equal(1, headlines.length)
    assert_equal({ level: 1, text: "Hello World" }, headlines[0])
  end

  def test_multiple_headlines
    md = <<~MD
      # Main Title
      Some content here.
      ## Section One
      More content.
      ### Subsection
      ## Section Two
    MD
    headlines = @gen.extract_headlines(md)
    assert_equal(4, headlines.length)
    assert_equal({ level: 1, text: "Main Title" }, headlines[0])
    assert_equal({ level: 2, text: "Section One" }, headlines[1])
    assert_equal({ level: 3, text: "Subsection" }, headlines[2])
    assert_equal({ level: 2, text: "Section Two" }, headlines[3])
  end

  def test_headline_with_bold
    md = "## Section **with bold**"
    headlines = @gen.extract_headlines(md)
    assert_equal(1, headlines.length)
    assert_equal({ level: 2, text: "Section with bold" }, headlines[0])
  end

  def test_headline_with_italic
    md = "## Section *with italic*"
    headlines = @gen.extract_headlines(md)
    assert_equal(1, headlines.length)
    assert_equal({ level: 2, text: "Section with italic" }, headlines[0])
  end

  def test_headline_with_link
    md = "## Section [with link](http://example.com)"
    headlines = @gen.extract_headlines(md)
    assert_equal(1, headlines.length)
    assert_equal({ level: 2, text: "Section with link" }, headlines[0])
  end

  def test_no_headlines
    md = "Just some plain text\nwithout any headlines."
    headlines = @gen.extract_headlines(md)
    assert_equal(0, headlines.length)
  end

  def test_all_heading_levels
    md = <<~MD
      # H1
      ## H2
      ### H3
      #### H4
      ##### H5
      ###### H6
    MD
    headlines = @gen.extract_headlines(md)
    assert_equal(6, headlines.length)
    (1..6).each do |level|
      assert_equal(level, headlines[level - 1][:level])
      assert_equal("H#{level}", headlines[level - 1][:text])
    end
  end
end
