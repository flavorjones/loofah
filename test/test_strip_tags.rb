require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class TestBasic < Test::Unit::TestCase

  def test_removal_of_all_tags
    html = <<-HTML
      What's up <strong>doc</strong>?
    HTML
    sane = Dryopteris.strip_tags(html)
    assert_equal "What's up doc?".strip, sane.strip
  end
  
end