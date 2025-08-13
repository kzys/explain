require 'simplecov'
SimpleCov.minimum_coverage 70
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
<h1>h1</h1>
<p>foo</p>
<hr />
<p>bar</p>
END

  end

  def test_h1_title_extraction
    vm = @gen.parse_file('test/h1_title.md')
    assert_equal('My H1 Title', vm.title)
    assert_match(%r{<h1>My H1 Title</h1>}, vm.content)
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
