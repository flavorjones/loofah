require "helper"

class UnitTestApi < Loofah::TestCase
  let(:html) { "<div>a</div>\n<div>b</div>" }
  let(:xml_fragment) { "<div>a</div>\n<div>b</div>" }
  let(:xml) { "<root>#{xml_fragment}</root>" }

  describe Loofah do
    it "creates html4 documents" do
      doc = Loofah.document(html)
      assert_kind_of(Loofah::HTML4::Document, doc)
      assert_equal html, doc.xpath("/html/body").inner_html
    end

    it "creates html4 fragments" do
      doc = Loofah.fragment(html)
      assert_kind_of(Loofah::HTML4::DocumentFragment, doc)
      assert_equal html, doc.inner_html
    end

    it "creates xml documents" do
      doc = Loofah.xml_document(xml)
      assert_kind_of(Loofah::XML::Document, doc)
      assert_equal xml, doc.root.to_xml
    end

    it "creates xml fragments" do
      doc = Loofah.xml_fragment(xml_fragment)
      assert_kind_of(Loofah::XML::DocumentFragment, doc)
      assert_equal xml_fragment, doc.children.to_xml
    end
  end

  describe Loofah::HTML4 do
    it "subclasses Nokogiri::HTML4" do
      assert_includes(Loofah::HTML4::Document.ancestors, Nokogiri::HTML4::Document)
      assert_includes(Loofah::HTML4::DocumentFragment.ancestors, Nokogiri::HTML4::DocumentFragment)
    end

    it "parses documents" do
      doc = Loofah::HTML4::Document.parse(html)
      assert_kind_of(Loofah::HTML4::Document, doc)
      assert_equal html, doc.xpath("/html/body").inner_html
    end

    it "parses document fragment" do
      doc = Loofah::HTML4::DocumentFragment.parse(html)
      assert_kind_of(Loofah::HTML4::DocumentFragment, doc)
      assert_equal html, doc.inner_html
    end

    it "scrubs documents" do
      doc = Loofah::HTML4::Document.parse(html).scrub!(:strip)
      assert_equal html, doc.xpath("/html/body").inner_html
    end

    it "scrubs fragments" do
      doc = Loofah::HTML4::DocumentFragment.parse(html).scrub!(:strip)
      assert_equal html, doc.inner_html
    end

    it "scrubs document nodes" do
      doc = Loofah::HTML4::Document.parse(html)
      assert(node = doc.at_css("div"))
      node.scrub!(:strip)
    end

    it "scrubs fragment nodes" do
      doc = Loofah.fragment(html)
      assert(node = doc.at_css("div"))
      node.scrub!(:strip)
    end

    it "scrubs document nodesets" do
      doc = Loofah.document(html)
      assert(node_set = doc.css("div"))
      assert_instance_of Nokogiri::XML::NodeSet, node_set
      node_set.scrub!(:strip)
    end

    it "scrubs fragment nodesets" do
      doc = Loofah.fragment(html)
      assert(node_set = doc.css("div"))
      assert_instance_of Nokogiri::XML::NodeSet, node_set
      node_set.scrub!(:strip)
    end

    it "exposes serialize_root on Loofah::HTML4::DocumentFragment" do
      doc = Loofah.fragment(html)
      assert_equal html, doc.serialize_root.to_html
    end

    it "exposes serialize_root on Loofah::HTML4::Document" do
      doc = Loofah.document(html)
      assert_equal html, doc.serialize_root.children.to_html
    end
  end

  describe Loofah::XML do
    it "subclasses Nokogiri::XML" do
      assert_includes(Loofah::XML::Document.ancestors, Nokogiri::XML::Document)
      assert_includes(Loofah::XML::DocumentFragment.ancestors, Nokogiri::XML::DocumentFragment)
    end

    it "parses documents" do
      doc = Loofah::XML::Document.parse(xml)
      assert_kind_of(Loofah::XML::Document, doc)
      assert_equal xml, doc.root.to_xml
    end

    it "parses document fragments" do
      doc = Loofah::XML::DocumentFragment.parse(xml_fragment)
      assert_kind_of(Loofah::XML::DocumentFragment, doc)
      assert_equal xml_fragment, doc.children.to_xml
    end

    it "scrubs documents" do
      scrubber = Loofah::Scrubber.new { |node| }
      doc = Loofah.xml_document(xml).scrub!(scrubber)
      assert_equal xml, doc.root.to_xml
    end

    it "scrubs fragments" do
      scrubber = Loofah::Scrubber.new { |node| }
      doc = Loofah.xml_fragment(xml_fragment).scrub!(scrubber)
      assert_equal xml_fragment, doc.children.to_xml
    end

    it "scrubs document nodes" do
      doc = Loofah.xml_document(xml)
      assert(node = doc.at_css("div"))
      node.scrub!(:strip)
    end

    it "scrubs fragment nodes" do
      doc = Loofah.xml_fragment(xml)
      assert(node = doc.at_css("div"))
      node.scrub!(:strip)
    end

    it "scrubs document nodesets" do
      doc = Loofah.xml_document(xml)
      assert(node_set = doc.css("div"))
      assert_instance_of Nokogiri::XML::NodeSet, node_set
      node_set.scrub!(:strip)
    end
  end

  describe Loofah::HTML do
    it "is aliased to Loofah::HTML4" do
      assert_equal(Loofah::HTML4, Loofah::HTML)
      assert_equal(Loofah::HTML4::Document, Loofah::HTML::Document)
      assert_equal(Loofah::HTML4::DocumentFragment, Loofah::HTML::DocumentFragment)
    end

    it "has an HTML4 name" do
      assert_equal("Loofah::HTML4", Loofah::HTML.to_s)
      assert_equal("Loofah::HTML4::Document", Loofah::HTML::Document.to_s)
      assert_equal("Loofah::HTML4::DocumentFragment", Loofah::HTML::DocumentFragment.to_s)
    end
  end
end
