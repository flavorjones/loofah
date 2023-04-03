# frozen_string_literal: true

require "helper"

class UnitTestApi < Loofah::TestCase
  let(:html) { "<div>a</div>\n<div>b</div>" }
  let(:xml_fragment) { "<div>a</div>\n<div>b</div>" }
  let(:xml) { "<root>#{xml_fragment}</root>" }
  let(:xml_scrubber) do
    Loofah::Scrubber.new do |node|
      # no-op
    end
  end

  describe Loofah do
    describe "generic class methods" do
      it "creates html4 documents" do
        doc = Loofah.document(html)

        assert_kind_of(Loofah::HTML4::Document, doc)
        assert_equal html, doc.xpath("/html/body").inner_html
      end

      it "scrubs html4 documents" do
        doc = Loofah.scrub_document(html, :strip)

        assert_kind_of(Loofah::HTML4::Document, doc)
        assert_equal html, doc.xpath("/html/body").inner_html
      end

      it "creates html4 fragments" do
        doc = Loofah.fragment(html)

        assert_kind_of(Loofah::HTML4::DocumentFragment, doc)
        assert_equal html, doc.inner_html
      end

      it "scrubs html4 fragments" do
        doc = Loofah.scrub_fragment(html, :strip)

        assert_kind_of(Loofah::HTML4::DocumentFragment, doc)
        assert_equal html, doc.inner_html
      end
    end

    describe "html4 methods" do
      it "creates html4 documents" do
        doc = Loofah.html4_document(html)

        assert_kind_of(Loofah::HTML4::Document, doc)
        assert_equal html, doc.xpath("/html/body").inner_html
      end

      it "scrubs html4 documents" do
        doc = Loofah.scrub_html4_document(html, :strip)

        assert_kind_of(Loofah::HTML4::Document, doc)
        assert_equal html, doc.xpath("/html/body").inner_html
      end

      it "creates html4 fragments" do
        doc = Loofah.html4_fragment(html)

        assert_kind_of(Loofah::HTML4::DocumentFragment, doc)
        assert_equal html, doc.inner_html
      end

      it "scrubs html4 fragments" do
        doc = Loofah.scrub_html4_fragment(html, :strip)

        assert_kind_of(Loofah::HTML4::DocumentFragment, doc)
        assert_equal html, doc.inner_html
      end
    end

    describe "html5 methods" do
      if Loofah.html5_support?
        it "creates html5 documents" do
          doc = Loofah.html5_document(html)

          assert_kind_of(Loofah::HTML5::Document, doc)
          assert_equal html, doc.xpath("/html/body").inner_html
        end

        it "scrubs html5 documents" do
          doc = Loofah.scrub_html5_document(html, :strip)

          assert_kind_of(Loofah::HTML5::Document, doc)
          assert_equal html, doc.xpath("/html/body").inner_html
        end

        it "creates html5 fragments" do
          doc = Loofah.html5_fragment(html)

          assert_kind_of(Loofah::HTML5::DocumentFragment, doc)
          assert_equal html, doc.inner_html
        end

        it "scrubs html5 fragments" do
          doc = Loofah.scrub_html5_fragment(html, :strip)

          assert_kind_of(Loofah::HTML5::DocumentFragment, doc)
          assert_equal html, doc.inner_html
        end
      else
        it "raises an error" do
          assert_raises(NotImplementedError) { Loofah.html5_document(html) }
          assert_raises(NotImplementedError) { Loofah.scrub_html5_document(html, :strip) }
          assert_raises(NotImplementedError) { Loofah.html5_fragment(html) }
          assert_raises(NotImplementedError) { Loofah.scrub_html5_fragment(html, :strip) }
        end
      end
    end

    describe "xml methods" do
      it "creates xml documents" do
        doc = Loofah.xml_document(xml)

        assert_kind_of(Loofah::XML::Document, doc)
        assert_equal xml, doc.root.to_xml
      end

      it "scrubs xml documents" do
        doc = Loofah.scrub_xml_document(xml, xml_scrubber)

        assert_kind_of(Loofah::XML::Document, doc)
        assert_equal xml, doc.root.to_xml
      end

      it "creates xml fragments" do
        doc = Loofah.xml_fragment(xml_fragment)

        assert_kind_of(Loofah::XML::DocumentFragment, doc)
        assert_equal xml_fragment, doc.children.to_xml
      end

      it "scrubs xml fragments" do
        doc = Loofah.scrub_xml_fragment(xml_fragment, :strip)

        assert_kind_of(Loofah::XML::DocumentFragment, doc)
        assert_equal xml_fragment, doc.children.to_xml
      end
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

    it "adds instance methods to documents" do
      doc = Loofah::HTML4::Document.parse(html)
      doc.scrub!(:strip)
    end

    it "adds instance methods to document nodes" do
      doc = Loofah::HTML4::Document.parse(html)

      assert(node = doc.at_css("div"))
      node.scrub!(:strip)
    end

    it "adds instance methods to fragments" do
      doc = Loofah::HTML4::DocumentFragment.parse(html)
      doc.scrub!(:strip)
    end

    it "adds instance methods to fragment nodes" do
      doc = Loofah::HTML4::DocumentFragment.parse(html)

      assert(node = doc.at_css("div"))
      node.scrub!(:strip)
    end

    it "adds instance methods to document nodesets" do
      doc = Loofah.html4_document(html)

      assert(node_set = doc.css("div"))
      assert_instance_of Nokogiri::XML::NodeSet, node_set
      node_set.scrub!(:strip)
    end

    it "adds instance methods to fragment nodesets" do
      doc = Loofah.html4_fragment(html)

      assert(node_set = doc.css("div"))
      assert_instance_of Nokogiri::XML::NodeSet, node_set
      node_set.scrub!(:strip)
    end

    it "exposes serialize_root on Loofah::HTML4::DocumentFragment" do
      doc = Loofah.html4_fragment(html)

      assert_equal html, doc.serialize_root.to_html
    end

    it "exposes serialize_root on Loofah::HTML4::Document" do
      doc = Loofah.html4_document(html)

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

    it "adds instance methods to documents" do
      doc = Loofah.xml_document(xml)
      scrubber = Loofah::Scrubber.new { |node| }
      doc.scrub!(scrubber)
    end

    it "adds instance methods to document nodes" do
      doc = Loofah.xml_document(xml)

      assert(node = doc.at_css("div"))
      node.scrub!(:strip)
    end

    it "adds instance methods to fragments" do
      doc = Loofah.xml_fragment(xml)
      doc.scrub!(:strip)
    end

    it "adds instance methods to fragment nodes" do
      doc = Loofah.xml_fragment(xml)

      assert(node = doc.at_css("div"))
      node.scrub!(:strip)
    end

    it "adds instance methods to document nodesets" do
      doc = Loofah.xml_document(xml)

      assert(node_set = doc.css("div"))
      assert_instance_of Nokogiri::XML::NodeSet, node_set
      node_set.scrub!(:strip)
    end

    it "adds instance methods to document nodesets" do
      doc = Loofah.xml_fragment(xml)

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
