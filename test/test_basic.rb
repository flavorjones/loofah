
require 'test/unit'
require 'dryopteris'

class TestBasic < Test::Unit::TestCase

  def test_removal_of_illegal_tag
    html = <<-HTML
      following this there should be no jim tag
      <jim>jim</jim>
      was there?
    HTML
    sane = Nokogiri::HTML(Dryopteris.sanitize(html))
    assert sane.xpath("//jim").empty?
  end

  def test_removal_of_illegal_attribute
    html = "<p class=bar foo=bar abbr=bar />"
    sane = Nokogiri::HTML(Dryopteris.sanitize(html))
    node = sane.xpath("//p").first
    assert node.attributes['class']
    assert node.attributes['abbr']
    assert_nil node.attributes['foo']
  end

  def test_removal_of_illegal_url_in_href
    html = <<-HTML
      <a href='jimbo://jim.jim/'>this link should have its href removed because of illegal url</a>
      <a href='http://jim.jim/'>this link should be fine</a>
    HTML
    sane = Nokogiri::HTML(Dryopteris.sanitize(html))
    nodes = sane.xpath("//a")
    assert_nil nodes.first.attributes['href']
    assert nodes.last.attributes['href']
  end

  def test_css_sanitization
    html = "<p style='background-color: url(\"http://foo.com/\") ; background-color: #000 ;' />"
    sane = Nokogiri::HTML(Dryopteris.sanitize(html))
    assert_match(/#000/, sane.inner_html)
    assert_no_match(/foo\.com/, sane.inner_html)
  end

end
