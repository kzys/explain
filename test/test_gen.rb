require 'simplecov'
SimpleCov.minimum_coverage 70
SimpleCov.start

require 'minitest/autorun'
require_relative '../gen'

class TestGen < Minitest::Test
  def test_front_matter
    g = Gen.new
    vm = g.parse_file('test/front_matter.md')
    assert_equal('from front matter', vm.title)
    assert_match(/hello world/, vm.content)
    assert_equal(true, vm.draft)
  end

  def test_markdown
    g = Gen.new
    vm = g.parse_file('test/markdown.md')
    assert_equal('h1', vm.title)
    assert_equal(<<END, vm.content)
<h1>h1</h1>
<p>foo</p>
<hr />
<p>bar</p>
END

  end

  def test_parse_git_log
    g = Gen.new
    log = File.read('testdata/git_log.txt')
    file_to_time = g.parse_git_log(log)
    assert(file_to_time)
  end
end
