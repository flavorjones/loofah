require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class TestBasic < Test::Unit::TestCase

  def test_nil
    assert_nil Dryopteris.strip_tags(nil)
  end
  
  def test_empty_string
    assert_equal Dryopteris.strip_tags(""), ""
  end
  
  def test_removal_of_all_tags
    html = <<-HTML
      What's up <strong>doc</strong>?
    HTML
    stripped = Dryopteris.strip_tags(html)
    assert_equal "What's up doc?".strip, stripped.strip
  end
  
end