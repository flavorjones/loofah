require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class TestScrubber < Test::Unit::TestCase

  [ Loofah::HTML::Document, Loofah::HTML::DocumentFragment ].each do |klass|
    define_method "test_#{klass}_bad_sanitize_method" do
      doc = klass.parse "<p>foo</p>"
      assert_raises(ArgumentError) { doc.scrub! :frippery }
    end
  end

  INVALID_FRAGMENT = "<invalid>foo<p>bar</p>bazz</invalid><div>quux</div>"
  INVALID_ESCAPED  = "&lt;invalid&gt;foo&lt;p&gt;bar&lt;/p&gt;bazz&lt;/invalid&gt;<div>quux</div>"
  INVALID_PRUNED   = "<div>quux</div>"
  INVALID_YANKED   = "foo<p>bar</p>bazz<div>quux</div>"

  WHITEWASH_FRAGMENT = "<o:div>no</o:div><div id='no'>foo</div><invalid>bar</invalid>"
  WHITEWASH_RESULT   = "<div>foo</div>"

  def test_document_escape_bad_tags
    doc = Loofah::HTML::Document.parse "<html><body>#{INVALID_FRAGMENT}</body></html>"
    result = doc.scrub! :escape

    assert_equal INVALID_ESCAPED, doc.xpath('/html/body').inner_html
    assert_equal doc, result
  end

  def test_fragment_escape_bad_tags
    doc = Loofah::HTML::DocumentFragment.parse "<div>#{INVALID_FRAGMENT}</div>"
    result = doc.scrub! :escape

    assert_equal INVALID_ESCAPED, doc.xpath("./div").inner_html
    assert_equal doc, result
  end

  def test_document_prune_bad_tags
    doc = Loofah::HTML::Document.parse "<html><body>#{INVALID_FRAGMENT}</body></html>"
    result = doc.scrub! :prune

    assert_equal INVALID_PRUNED, doc.xpath('/html/body').inner_html
    assert_equal doc, result
  end

  def test_fragment_prune_bad_tags
    doc = Loofah::HTML::DocumentFragment.parse "<div>#{INVALID_FRAGMENT}</div>"
    result = doc.scrub! :prune

    assert_equal INVALID_PRUNED, doc.xpath("./div").inner_html
    assert_equal doc, result
  end

  def test_document_yank_bad_tags
    doc = Loofah::HTML::Document.parse "<html><body>#{INVALID_FRAGMENT}</body></html>"
    result = doc.scrub! :yank

    assert_equal INVALID_YANKED, doc.xpath('/html/body').inner_html
    assert_equal doc, result
  end

  def test_fragment_yank_bad_tags
    doc = Loofah::HTML::DocumentFragment.parse "<div>#{INVALID_FRAGMENT}</div>"
    result = doc.scrub! :yank

    assert_equal INVALID_YANKED, doc.xpath("./div").inner_html
    assert_equal doc, result
  end

  def test_document_whitewash
    doc = Loofah::HTML::Document.parse "<html><body>#{WHITEWASH_FRAGMENT}</body></html>"
    result = doc.scrub! :whitewash

    assert_equal WHITEWASH_RESULT, doc.xpath('/html/body').inner_html
    assert_equal doc, result
  end

  def test_fragment_whitewash
    doc = Loofah::HTML::DocumentFragment.parse "<div>#{WHITEWASH_FRAGMENT}</div>"
    result = doc.scrub! :whitewash

    assert_equal WHITEWASH_RESULT, doc.xpath("./div").inner_html
    assert_equal doc, result
  end

end
