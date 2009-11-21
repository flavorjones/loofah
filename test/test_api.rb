require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class TestApi < Test::Unit::TestCase

  HTML          = "<div>a</div>\n<div>b</div>"
  XML_FRAGMENT  = "<div>a</div>\n<div>b</div>"
  XML           = "<root>#{XML_FRAGMENT}</root>"

  def test_loofah_document
    doc = Loofah.document(HTML)
    assert_html_documentish doc
  end

  def test_loofah_fragment
    doc = Loofah.fragment(HTML)
    assert_html_fragmentish doc
  end

  def test_loofah_xml_document
    doc = Loofah.xml_document(XML)
    assert_xml_documentish doc
  end

  def test_loofah_xml_fragment
    doc = Loofah.xml_fragment(XML_FRAGMENT)
    assert_xml_fragmentish doc
  end

  def test_loofah_html_document_parse_method
    doc = Loofah::HTML::Document.parse(HTML)
    assert_html_documentish doc
  end

  def test_loofah_xml_document_parse_method
    doc = Loofah::XML::Document.parse(XML)
    assert_xml_documentish doc
  end

  def test_loofah_html_document_fragment_parse_method
    doc = Loofah::HTML::DocumentFragment.parse(HTML)
    assert_html_fragmentish doc
  end

  def test_loofah_xml_document_fragment_parse_method
    doc = Loofah::XML::DocumentFragment.parse(XML_FRAGMENT)
    assert_xml_fragmentish doc
  end

  def test_loofah_document_scrub!
    doc = Loofah.document(HTML).scrub!(:strip)
    assert_html_documentish doc
  end

  def test_loofah_fragment_scrub!
    doc = Loofah.fragment(HTML).scrub!(:strip)
    assert_html_fragmentish doc
  end

  def test_loofah_xml_document_scrub!
    scrubber = Loofah::Scrubber.new { |node| }
    doc = Loofah.xml_document(XML).scrub!(scrubber)
    assert_xml_documentish doc
  end

  def test_loofah_xml_fragment_scrub!
    scrubber = Loofah::Scrubber.new { |node| }
    doc = Loofah.xml_fragment(XML_FRAGMENT).scrub!(scrubber)
    assert_xml_fragmentish doc
  end

  private

  def assert_html_documentish(doc)
    assert_kind_of Nokogiri::HTML::Document, doc
    assert_kind_of Loofah::HTML::Document,   doc
    assert_equal HTML, doc.xpath("/html/body").inner_html
  end

  def assert_html_fragmentish(doc)
    assert_kind_of Nokogiri::HTML::DocumentFragment, doc
    assert_kind_of Loofah::HTML::DocumentFragment,   doc
    assert_equal HTML, doc.inner_html
  end

  def assert_xml_documentish(doc)
    assert_kind_of Nokogiri::XML::Document, doc
    assert_kind_of Loofah::XML::Document,   doc
    assert_equal XML, doc.root.to_xml
  end

  def assert_xml_fragmentish(doc)
    assert_kind_of Nokogiri::XML::DocumentFragment, doc
    assert_kind_of Loofah::XML::DocumentFragment,   doc
    assert_equal XML_FRAGMENT, doc.children.to_xml
  end

end
