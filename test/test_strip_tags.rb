require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class TestStripTags < Test::Unit::TestCase

  def test_nil
    assert_nil Dryopteris.strip_tags(nil)
  end
  
  def test_empty_string
    assert_equal Dryopteris.strip_tags(""), ""
  end
  
  def test_return_empty_string_when_nothing_left
    assert_equal "", Dryopteris.strip_tags('<script>test</script>')
  end
  
  def test_removal_of_all_tags
    html = <<-HTML
      What's up <strong>doc</strong>?
    HTML
    stripped = Dryopteris.strip_tags(html)
    assert_equal "What's up doc?".strip, stripped.strip
  end
  
  def test_dont_remove_whitespace
    html = "Foo\nBar"
    assert_equal html, Dryopteris.strip_tags(html)
  end
  
  def test_dont_remove_whitespace_between_tags
    html = "<p>Foo</p>\n<p>Bar</p>"
    assert_equal "Foo\nBar", Dryopteris.strip_tags(html)
  end
  
end