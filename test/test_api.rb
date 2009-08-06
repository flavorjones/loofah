require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class TestApi < Test::Unit::TestCase

  HTML = "<div>a</div>\n<div>b</div>"

  def test_loofah_document
    doc = Loofah.document(HTML)
    assert_html_documentish doc
  end

  def test_loofah_fragment
    doc = Loofah.fragment(HTML)
    assert_html_fragmentish doc
  end

  def test_loofah_html_document_parse_method
    doc = Loofah::HTML::Document.parse(HTML)
    assert_html_documentish doc
  end

  def test_loofah_html_document_fragment_parse_method
    doc = Loofah::HTML::DocumentFragment.parse(HTML)
    assert_html_fragmentish doc
  end

  def test_loofah_document_scrub!
    doc = Loofah.document(HTML).scrub!(:yank)
    assert_html_documentish doc
  end

  def test_loofah_fragment_scrub!
    doc = Loofah.fragment(HTML).scrub!(:yank)
    assert_html_fragmentish doc
  end

  private

  def assert_html_documentish(doc)
    assert_kind_of Nokogiri::HTML::Document,   doc
    assert_kind_of Loofah::HTML::Document, doc
    assert_equal HTML, doc.xpath("/html/body").inner_html
  end

  def assert_html_fragmentish(doc)
    assert_kind_of Nokogiri::HTML::DocumentFragment,   doc
    assert_kind_of Loofah::HTML::DocumentFragment, doc
    assert_equal HTML, doc.inner_html
  end

end
