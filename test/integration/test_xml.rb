# frozen_string_literal: true

require "helper"

class IntegrationTestXml < Loofah::TestCase
  context "integration test" do
    context "xml document" do
      context "custom scrubber" do
        it "act as expected" do
          xml = Loofah.xml_document(<<~XML)
            <root>
              <employee deceased='true'>Abraham Lincoln</employee>
              <employee deceased='false'>Abe Vigoda</employee>
            </root>
          XML
          bring_out_your_dead = Loofah::Scrubber.new do |node|
            if (node.name == "employee") && (node["deceased"] == "true")
              node.remove
              Loofah::Scrubber::STOP # don't bother with the rest of the subtree
            end
          end

          assert_equal 2, xml.css("employee").length

          xml.scrub!(bring_out_your_dead)

          employees = xml.css("employee")

          assert_equal 1, employees.length
          assert_equal "Abe Vigoda", employees.first.inner_text
        end
      end

      context ":whitewash" do
        it "escapes CDATA content" do
          xml = Loofah.xml_document("<div><p>hello<![CDATA[</p><script>alert(1)</script><p>]]>world</p></div>")
          xml.scrub!(:whitewash)

          assert_equal(
            "<p>hello<![CDATA[&lt;/p&gt;&lt;script&gt;alert(1)&lt;/script&gt;&lt;p&gt;]]>world</p>",
            xml.at_css("p").to_xml,
          )
        end
      end
    end

    context "xml fragment" do
      context "custom scrubber" do
        it "act as expected" do
          xml = Loofah.xml_fragment(<<~XML)
            <employee deceased='true'>Abraham Lincoln</employee>
            <employee deceased='false'>Abe Vigoda</employee>
          XML
          bring_out_your_dead = Loofah::Scrubber.new do |node|
            if (node.name == "employee") && (node["deceased"] == "true")
              node.remove
              Loofah::Scrubber::STOP # don't bother with the rest of the subtree
            end
          end

          assert_equal 2, xml.css("employee").length

          xml.scrub!(bring_out_your_dead)

          employees = xml.css("employee")

          assert_equal 1, employees.length
          assert_equal "Abe Vigoda", employees.first.inner_text
        end
      end

      context ":whitewash" do
        it "escapes CDATA content" do
          xml = Loofah.xml_fragment("<p>hello<![CDATA[</p><script>alert(1)</script><p>]]>world</p>")
          xml.scrub!(:whitewash)

          assert_equal(
            "<p>hello<![CDATA[&lt;/p&gt;&lt;script&gt;alert(1)&lt;/script&gt;&lt;p&gt;]]>world</p>",
            xml.to_s,
          )
        end
      end
    end
  end
end
