require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class TestSanitize < Test::Unit::TestCase

  [ Dryopteris::HTML::Document, Dryopteris::HTML::DocumentFragment ].each do |klass|
    define_method "test_#{klass}_bad_sanitize_method" do
      doc = klass.parse "<p>foo</p>"
      assert_raises(ArgumentError) { doc.sanitize :frippery }
    end
  end

  INVALID_FRAGMENT = "<invalid>foo<p>bar</p>bazz</invalid><div>quux</div>"
  INVALID_ESCAPED  = "&lt;invalid&gt;foo&lt;p&gt;bar&lt;/p&gt;bazz&lt;/invalid&gt;<div>quux</div>"
  INVALID_PRUNED   = "<div>quux</div>"
  INVALID_YANKED   = "foo<p>bar</p>bazz<div>quux</div>"

  def test_document_escape_bad_tags
    doc = Dryopteris::HTML::Document "<html><body>#{INVALID_FRAGMENT}</body></html>"
    result = doc.sanitize :escape

    assert_equal INVALID_ESCAPED, doc.xpath('/html/body').inner_html
    assert_equal doc, result
  end

  def test_fragment_escape_bad_tags
    doc = Dryopteris::HTML::DocumentFragment "<div>#{INVALID_FRAGMENT}</div>"
    result = doc.sanitize :escape

    assert_equal INVALID_ESCAPED, doc.xpath("./div").inner_html
    assert_equal doc, result
  end

  def test_document_prune_bad_tags
    doc = Dryopteris::HTML::Document "<html><body>#{INVALID_FRAGMENT}</body></html>"
    result = doc.sanitize :prune

    assert_equal INVALID_PRUNED, doc.xpath('/html/body').inner_html
    assert_equal doc, result
  end

  def test_fragment_prune_bad_tags
    doc = Dryopteris::HTML::DocumentFragment "<div>#{INVALID_FRAGMENT}</div>"
    result = doc.sanitize :prune

    assert_equal INVALID_PRUNED, doc.xpath("./div").inner_html
    assert_equal doc, result
  end

  def test_document_yank_bad_tags
    doc = Dryopteris::HTML::Document "<html><body>#{INVALID_FRAGMENT}</body></html>"
    result = doc.sanitize :yank

    assert_equal INVALID_YANKED, doc.xpath('/html/body').inner_html
    assert_equal doc, result
  end

  def test_fragment_yank_bad_tags
    doc = Dryopteris::HTML::DocumentFragment "<div>#{INVALID_FRAGMENT}</div>"
    result = doc.sanitize :yank

    assert_equal INVALID_YANKED, doc.xpath("./div").inner_html
    assert_equal doc, result
  end

#   def test_yanking_bad_tags_from_document
#     doc = Dryopteris("<html><body><invalid>foo<p>bar<invalid>fuzz</invalid>wuzz</p>bazz</invalid></body></html>")
#     result = doc.sanitize(:yank)

#     assert_equal "<body>foo<p>barfuzzwuzz</p>bazz</body>", doc.xpath('/html/body').first.to_html
#     assert_equal doc, result
#   end

#   def test_yanking_bad_tags_from_fragment
#     doc = Dryopteris::Fragment("<div><invalid>foo<p>bar<invalid>fuzz</invalid>wuzz</p>bazz</invalid></div>")
#     result = doc.sanitize(:yank)

#     assert_equal "<div>foo<p>barfuzzwuzz</p>bazz</div>", doc.xpath('./div').first.to_html
#     assert_equal doc, result
#   end

  #   def test_unfiltered_output
  #     doc.to_html
  #   end

  #   def test_removing_attributes_output
  #     doc.to_html(:scrub => true)
  #   end

  #   def test_printable_text_output
  #     doc.to_s
  #   end

end
