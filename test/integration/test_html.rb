# frozen_string_literal: true

require "helper"

class IntegrationTestHtml < Loofah::TestCase
  LOOFAH_HTML_VERSIONS.each do |html_version|
    context "#{html_version} fragment" do
      context "#to_s" do
        it "includes header tags (like style)" do
          html = "<style>foo</style><div>bar</div>"
          expected = "<style>foo</style><div>bar</div>"

          assert_equal(expected, Loofah.send("#{html_version}_fragment", html).to_s)

          # assumption check is that Nokogiri does the same
          assert_equal(expected, Nokogiri::HTML4::DocumentFragment.parse(html).to_s)
          if Nokogiri.uses_gumbo?
            assert_equal(expected, Nokogiri::HTML5::DocumentFragment.parse(html).to_s)
          end
        end
      end

      context "#text" do
        it "includes header tags (like style)" do
          html = "<style>foo</style><div>bar</div>"
          expected = "foobar"

          assert_equal(expected, Loofah.send("#{html_version}_fragment", html).text)

          # assumption check is that Nokogiri does the same
          assert_equal(expected, Nokogiri::HTML4::DocumentFragment.parse(html).text)
          if Nokogiri.uses_gumbo?
            assert_equal(expected, Nokogiri::HTML5::DocumentFragment.parse(html).text)
          end
        end

        it "does not include cdata tags (like comments)" do
          html = "<div>bar<!-- comment1 --></div><!-- comment2 -->"
          expected = "bar"

          assert_equal(expected, Loofah.send("#{html_version}_fragment", html).text)

          # assumption check is that Nokogiri does the same
          assert_equal(expected, Nokogiri::HTML4::DocumentFragment.parse(html).text)
          if Nokogiri.uses_gumbo?
            assert_equal(expected, Nokogiri::HTML5::DocumentFragment.parse(html).text)
          end
        end
      end

      context "#to_text" do
        it "add newlines before and after html4 block elements" do
          html = Loofah.send(
            "#{html_version}_fragment",
            "<div>tweedle<h1>beetle</h1>bottle<span>puddle</span>paddle<div>battle</div>muddle</div>",
          )

          assert_equal "\ntweedle\nbeetle\nbottlepuddlepaddle\nbattle\nmuddle\n", html.to_text
        end

        it "add newlines before and after html5 block elements" do
          html = Loofah.send(
            "#{html_version}_fragment",
            "<div>tweedle<section>beetle</section>bottle<span>puddle</span>paddle<div>battle</div>muddle</div>",
          )

          assert_equal "\ntweedle\nbeetle\nbottlepuddlepaddle\nbattle\nmuddle\n", html.to_text
        end

        it "remove extraneous whitespace" do
          html = Loofah.send(
            "#{html_version}_fragment",
            "<div>tweedle\n\n\t\n\s\nbeetle</div>",
          )

          assert_equal "\ntweedle\n\nbeetle\n", html.to_text
        end

        it "replaces <br> with newlines" do
          html = Loofah.send(
            "#{html_version}_fragment",
            "hello<div>first line<br>second line</div>goodbye",
          )

          assert_equal("hello\nfirst line\nsecond line\ngoodbye", html.to_text)
        end
      end

      context "with an `encoding` arg" do
        it "sets the parent document's encoding to accordingly" do
          html = Loofah.send(
            "#{html_version}_fragment",
            "<style>foo</style><div>bar</div>",
            "US-ASCII",
          )

          assert_equal "US-ASCII", html.document.encoding
        end
      end
    end

    context "#{html_version} document" do
      context "#text" do
        it "not include head tags (like style)" do
          html = Loofah.send(
            "#{html_version}_document",
            "<style>foo</style><div>bar</div>",
          )

          assert_equal "bar", html.text
        end
      end

      context "#to_text" do
        it "add newlines before and after html4 block elements" do
          html = Loofah.send(
            "#{html_version}_document",
            "<div>tweedle<h1>beetle</h1>bottle<span>puddle</span>paddle<div>battle</div>muddle</div>",
          )

          assert_equal "\ntweedle\nbeetle\nbottlepuddlepaddle\nbattle\nmuddle\n", html.to_text
        end

        it "add newlines before and after html5 block elements" do
          html = Loofah.send(
            "#{html_version}_document",
            "<div>tweedle<section>beetle</section>bottle<span>puddle</span>paddle<div>battle</div>muddle</div>",
          )

          assert_equal "\ntweedle\nbeetle\nbottlepuddlepaddle\nbattle\nmuddle\n", html.to_text
        end

        it "remove extraneous whitespace" do
          html = Loofah.send(
            "#{html_version}_document",
            "<div>tweedle\n\n\t\n\s\nbeetle</div>",
          )

          assert_equal "\ntweedle\n\nbeetle\n", html.to_text
        end

        it "replaces <br> with newlines" do
          html = Loofah.send(
            "#{html_version}_document",
            "<body>hello<div>first line<br>second line</div>goodbye</body>",
          )

          assert_equal("hello\nfirst line\nsecond line\ngoodbye", html.to_text)
        end
      end
    end
  end
end
