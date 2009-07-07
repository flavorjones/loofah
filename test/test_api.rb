require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class TestApi < Test::Unit::TestCase

  HTML = "<div>a</div>\n<div>b</div>"

  def test_dryopteris_document
    doc = Dryopteris.document(HTML)
    assert_html_documentish doc
  end

  def test_dryopteris_fragment
    doc = Dryopteris.fragment(HTML)
    assert_html_fragmentish doc
  end

  def test_dryopteris_html_document_parse_method
    doc = Dryopteris::HTML::Document.parse(HTML)
    assert_html_documentish doc
  end

  def test_dryopteris_html_document_fragment_parse_method
    doc = Dryopteris::HTML::DocumentFragment.parse(HTML)
    assert_html_fragmentish doc
  end

  private

  def assert_html_documentish(doc)
    assert_kind_of Nokogiri::HTML::Document,   doc
    assert_kind_of Dryopteris::HTML::Document, doc
    assert_equal HTML, doc.xpath("/html/body").inner_html
  end

  def assert_html_fragmentish(doc)
    assert_kind_of Nokogiri::HTML::DocumentFragment,   doc
    assert_kind_of Dryopteris::HTML::DocumentFragment, doc
    assert_equal HTML, doc.inner_html
  end

end
