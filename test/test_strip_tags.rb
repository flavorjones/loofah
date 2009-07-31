require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class TestStripTags < Test::Unit::TestCase

  def test_empty_string
    assert_equal Loofah.strip_tags(""), ""
  end
  
  def test_return_empty_string_when_nothing_left
    assert_equal "", Loofah.strip_tags('<script>test</script>')
  end
  
  def test_removal_of_all_tags
    html = <<-HTML
      What's up <strong>doc</strong>?
    HTML
    stripped = Loofah.strip_tags(html)
    assert_equal "What's up doc?".strip, stripped.strip
  end
  
  def test_dont_remove_whitespace
    html = "Foo\nBar"
    assert_equal html, Loofah.strip_tags(html)
  end
  
  def test_dont_remove_whitespace_between_tags
    html = "<p>Foo</p>\n<p>Bar</p>"
    assert_equal "Foo\nBar", Loofah.strip_tags(html)
  end
  
  def test_removal_of_entities
    html = "<p>this is &lt; that &quot;&amp;&quot; the other &gt; boo&apos;ya</p>"
    assert_equal 'this is < that "&" the other > boo\'ya', Loofah.strip_tags(html)
  end
  
end
