require "helper"

class IntegrationTestAdHoc < Loofah::TestCase
  context "blank input string" do
    context "fragment" do
      it "return a blank string" do
        assert_equal "", Loofah.scrub_fragment("", :prune).to_s
      end
    end

    context "document" do
      it "return a blank string" do
        expected = html5_mode? ? "<html><head></head><body></body></html>" : ""
        assert_equal expected, Loofah.scrub_document("", :prune).root.to_s
      end
    end
  end

  context "tests" do
    MSWORD_HTML = File.read(File.join(File.dirname(__FILE__), "..", "assets", "msword.html")).freeze

    def test_removal_of_illegal_tag
      html = <<-HTML
      following this there should be no jim tag
      <jim>jim</jim>
      was there?
    HTML
      sane = Nokogiri::HTML(Loofah.scrub_fragment(html, :escape).to_xml)
      assert sane.xpath("//jim").empty?
    end

    def test_removal_of_illegal_attribute
      html = "<p class=bar foo=bar abbr=bar />"
      sane = Nokogiri::HTML(Loofah.scrub_fragment(html, :escape).to_xml)
      node = sane.xpath("//p").first
      assert node.attributes["class"]
      assert node.attributes["abbr"]
      assert_nil node.attributes["foo"]
    end

    def test_removal_of_illegal_url_in_href
      html = <<-HTML
      <a href='jimbo://jim.jim/'>this link should have its href removed because of illegal url</a>
      <a href='http://jim.jim/'>this link should be fine</a>
    HTML
      sane = Nokogiri::HTML(Loofah.scrub_fragment(html, :escape).to_xml)
      nodes = sane.xpath("//a")
      assert_nil nodes.first.attributes["href"]
      assert nodes.last.attributes["href"]
    end

    def test_css_sanitization
      html = "<p style='background-color: url(\"http://foo.com/\") ; background-color: #000 ;' />"
      sane = Nokogiri::HTML(Loofah.scrub_fragment(html, :escape).to_xml)
      assert_match %r/#000/, sane.inner_html
      refute_match %r/foo\.com/, sane.inner_html
    end

    def test_fragment_with_no_tags
      assert_equal "This fragment has no tags.", Loofah.scrub_fragment("This fragment has no tags.", :escape).to_xml
    end

    def test_fragment_in_p_tag
      assert_equal "<p>This fragment is in a p.</p>", Loofah.scrub_fragment("<p>This fragment is in a p.</p>", :escape).to_xml
    end

    def test_fragment_in_p_tag_plus_stuff
      assert_equal "<p>This fragment is in a p.</p>foo<strong>bar</strong>", Loofah.scrub_fragment("<p>This fragment is in a p.</p>foo<strong>bar</strong>", :escape).to_xml
    end

    def test_fragment_with_text_nodes_leading_and_trailing
      assert_equal "text<p>fragment</p>text", Loofah.scrub_fragment("text<p>fragment</p>text", :escape).to_xml
    end

    def test_whitewash_on_fragment
      html = "<div>safe</div><frameset rows=\"*\"><frame src=\"http://example.com\"></frameset> <b>description</b>"
      whitewashed = Loofah.scrub_document(html, :whitewash).xpath("/html/body/*").to_s
      assert_equal "<div>safe</div><b>description</b>", whitewashed.gsub("\n", "")
    end

    def test_fragment_whitewash_on_microsofty_markup
      whitewashed = Loofah.fragment(MSWORD_HTML).scrub!(:whitewash)
      if Nokogiri.uses_libxml?("< 2.9.11") || html5_mode?
        assert_equal "<p>Foo <b>BOLD</b></p>", whitewashed.to_s.strip
      else
        assert_equal "<p>Foo <b>BOLD<p></p></b></p>", whitewashed.to_s.strip
      end
    end

    def test_document_whitewash_on_microsofty_markup
      whitewashed = Loofah.document(MSWORD_HTML).scrub!(:whitewash)
      if Nokogiri.uses_libxml?("< 2.9.11") || html5_mode?
        assert_equal "<p>Foo <b>BOLD</b></p>", whitewashed.xpath("/html/body/*").to_s
      else
        assert_equal "<p>Foo <b>BOLD<p></p></b></p>", whitewashed.xpath("/html/body/*").to_s
      end
    end

    def test_return_empty_string_when_nothing_left
      assert_equal "", Loofah.scrub_document("<script>test</script>", :prune).text
    end

    def test_nested_script_cdata_tags_should_be_scrubbed
      html = "<script><script src='malicious.js'></script>"
      stripped = Loofah.fragment(html).scrub!(:strip)
      assert_empty stripped.xpath("//script")
      refute_match("<script", stripped.to_html)
    end

    def test_nested_script_cdata_tags_should_be_scrubbed_2
      html = "<script><script>alert('a');</script></script>"
      stripped = Loofah.fragment(html).scrub!(:strip)
      assert_empty stripped.xpath("//script")
      refute_match("<script", stripped.to_html)
    end

    def test_removal_of_all_tags
      html = <<-HTML
      What's up <strong>doc</strong>?
    HTML
      stripped = Loofah.scrub_document(html, :prune).text
      assert_equal %Q(What\'s up doc?).strip, stripped.strip
    end

    def test_dont_remove_whitespace
      html = "Foo\nBar"
      assert_equal html, Loofah.scrub_document(html, :prune).text
    end

    def test_dont_remove_whitespace_between_tags
      html = "<p>Foo</p>\n<p>Bar</p>"
      assert_equal "Foo\nBar", Loofah.scrub_document(html, :prune).text
    end

    #
    #  tests for CVE-2018-8048 (see https://github.com/flavorjones/loofah/issues/144)
    #
    #  libxml2 >= 2.9.2 fails to escape comments within some attributes. It
    #  wants to ensure these comments can be treated as "server-side includes",
    #  but as a result fails to ensure that serialization is well-formed,
    #  resulting in an opportunity for XSS injection of code into a final
    #  re-parsed document (presumably in a browser).
    #
    #  we'll test this by parsing the HTML, serializing it, then
    #  re-parsing it to ensure there isn't any ambiguity in the output
    #  that might allow code injection into a browser consuming
    #  "sanitized" output.
    #
    [
      #
      #  these tags and attributes are determined by the code at:
      #
      #    https://git.gnome.org/browse/libxml2/tree/HTMLtree.c?h=v2.9.2#n714
      #
      { tag: "a", attr: "href" },
      { tag: "div", attr: "href" },
      { tag: "a", attr: "action" },
      { tag: "div", attr: "action" },
      { tag: "a", attr: "src" },
      { tag: "div", attr: "src" },
      { tag: "a", attr: "name" },
      #
      #  note that div+name is _not_ affected by the libxml2 issue.
      #  but we test it anyway to ensure our logic isn't modifying
      #  attributes that don't need modifying.
      #
      { tag: "div", attr: "name", unescaped: true },
    ].each do |config|
      define_method "test_uri_escaping_of_#{config[:attr]}_attr_in_#{config[:tag]}_tag" do
        html = %{<#{config[:tag]} #{config[:attr]}='examp<!--" unsafeattr=foo()>-->le.com'>test</#{config[:tag]}>}

        reparsed = Loofah.fragment(Loofah.fragment(html).scrub!(:prune).to_html)
        attributes = reparsed.at_css(config[:tag]).attribute_nodes

        assert_equal [config[:attr]], attributes.collect(&:name)
        if Nokogiri::VersionInfo.instance.libxml2?
          if config[:unescaped]
            #
            #  this attribute was emitted wrapped in single-quotes, so a double quote is A-OK.
            #  assert that this attribute's serialization is unaffected.
            #
            assert_equal %{examp<!--" unsafeattr=foo()>-->le.com}, attributes.first.value
          else
            #
            #  let's match the behavior in libxml < 2.9.2.
            #  test that this attribute's serialization is well-formed and sanitized.
            #
            assert_equal %{examp<!--%22%20unsafeattr=foo()>-->le.com}, attributes.first.value
          end
        else
          #
          #  yay for consistency in javaland. move along, nothing to see here.
          #
          assert_equal %{examp<!--%22 unsafeattr=foo()>-->le.com}, attributes.first.value
        end
      end
    end

    it "allows aria attributes" do
      html = <<~HTML
        <div role="application" aria-label="calendar"
             aria-description="Game schedule for the Boston Red Sox 2021 Season">
          <h1>Red Sox 2021</h1>
        </div>
      HTML

      sanitized = Loofah.scrub_fragment(html, :escape)
      attributes = sanitized.at_css("div").attributes
      assert_includes(attributes.keys, "role")
      assert_includes(attributes.keys, "aria-label")
      assert_includes(attributes.keys, "aria-description")
    end

    context "xss protection from svg animate attributes" do
      # see recommendation from https://html5sec.org/#137
      # to sanitize "to", "from", "values", and "by" attributes

      it "sanitizes 'from', 'to', and 'by' attributes" do
        # for CVE-2018-16468
        # see:
        # - https://github.com/flavorjones/loofah/issues/154
        # - https://hackerone.com/reports/429267
        html = %Q{<svg><a xmlns:xlink=http://www.w3.org/1999/xlink xlink:href=?><circle r=400 /><animate attributeName=xlink:href begin=0 from=javascript:alert(1) to=%26 by=5>}

        sanitized = Loofah.scrub_fragment(html, :escape)
        assert_nil sanitized.at_css("animate")["from"]
        assert_nil sanitized.at_css("animate")["to"]
        assert_nil sanitized.at_css("animate")["by"]
      end

      it "sanitizes 'values' attribute" do
        # for CVE-2019-15587
        # see:
        # - https://github.com/flavorjones/loofah/issues/171
        # - https://hackerone.com/reports/709009
        html = %Q{<svg> <animate href="#foo" attributeName="href" values="javascript:alert('xss')"/> <a id="foo"> <circle r=400 /> </a> </svg>}

        sanitized = Loofah.scrub_fragment(html, :escape)
        assert_nil sanitized.at_css("animate")["values"]
      end
    end

    #
    #  brought up by https://github.com/flavorjones/loofah/issues/80
    #
    context "comments outside html" do
      context "bare comments" do
        let(:html) { "<!-- --!><script>alert(1)</script><!-- -->" }

        it "Loofah.document removes the comment" do
          sanitized = Loofah.document(html)
          refute(sanitized.children.any? { |node| node.comment? } )
        end

        it "Loofah.scrub_document removes the comment" do
          sanitized = Loofah.scrub_document(html, :prune)
          sanitized_html = sanitized.to_html
          refute_match(/--/, sanitized_html)
        end
      end

      context "doc with comments outside HTML" do
        let(:html) do
          <<~EOF
            <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
                <!-- spaces ->
            		<!-- tabs -->
                     <!-- more spaces -->
            <html><body><div>hello
          EOF
        end

        it "Loofah.document removes the comment" do
          sanitized = Loofah.document(html)
          sanitized_html = sanitized.to_html
          refute_match(/--/, sanitized_html)
        end

        it "Loofah.scrub_document removes the comment" do
          sanitized = Loofah.scrub_document(html, :prune)
          sanitized_html = sanitized.to_html
          refute_match(/--/, sanitized_html)
        end
      end
    end

    it "handles property string values" do
      input = <<~EOF
        <span style="font-size: 36px; font-family: 'AvenirNext-Regular';">variation 1a</span>
        <span style="font-size: 36px; font-family: AvenirNext-Regular;">variation 1b</span>
        <span style="font-size: 36px; font-family: 'Avenir Next';">variation 2a</span>
        <span style="font-size: 36px; font-family: Avenir Next;">variation 2b</span>
      EOF

      expected = <<~EOF
        <span style="font-size:36px;font-family:'AvenirNext-Regular';">variation 1a</span>
        <span style="font-size:36px;font-family:AvenirNext-Regular;">variation 1b</span>
        <span style="font-size:36px;font-family:'Avenir Next';">variation 2a</span>
        <span style="font-size:36px;font-family:Avenir Next;">variation 2b</span>
      EOF

      actual = Loofah.scrub_fragment(input, :escape)

      assert_equal(expected, actual.to_html)
    end

    it "allows border-collapse property values" do
      # https://github.com/flavorjones/loofah/issues/201
      # https://developer.mozilla.org/en-US/docs/Web/CSS/border-collapse
      input = <<~EOF
        <table style='border-collapse: collapse;'></table>
        <table style='border-collapse: separate;'></table>
        <table style='border-collapse: not-allowed;'></table>
        <table style='border-collapse: inherit;'></table>
        <table style='border-collapse: initial;'></table>
        <table style='border-collapse: revert;'></table>
        <table style='border-collapse: unset;'></table>
      EOF

      expected = <<~EOF
        <table style=\"border-collapse:collapse;\"></table>
        <table style=\"border-collapse:separate;\"></table>
        <table></table>
        <table style=\"border-collapse:inherit;\"></table>
        <table style=\"border-collapse:initial;\"></table>
        <table style=\"border-collapse:revert;\"></table>
        <table style=\"border-collapse:unset;\"></table>
      EOF

      actual = Loofah.scrub_fragment(input, :escape)

      assert_equal(expected, actual.to_html)
    end

    describe "entities" do
      it "handles & character" do
        input = %{<div> this & that </div>}
        expected = %{<div> this &amp; that </div>}
        actual = Loofah.scrub_fragment(input, :escape)
        assert_equal(expected, actual.to_html)
      end

      it "handles > character" do
        input = %{<div> this > that </div>}
        expected = %{<div> this &gt; that </div>}
        actual = Loofah.scrub_fragment(input, :escape)
        assert_equal(expected, actual.to_html)
      end

      it "handles < character" do
        input = %{<div> this < that </div>}
        expected = %{<div> this &lt; that </div>}
        actual = Loofah.scrub_fragment(input, :escape)
        assert_equal(expected, actual.to_html)
      end

      it "handles < character in an attribute" do
        input = %{<div alt="this < that">wave</div>}
        expected = if html5_mode?
          # https://html.spec.whatwg.org/multipage/parsing.html#escapingString
          %{<div alt="this < that">wave</div>} # libgumbo
        else
          %{<div alt="this &lt; that">wave</div>}
        end
        actual = Loofah.scrub_fragment(input, :escape)
        assert_equal(expected, actual.to_html)
      end

      it "handles multiple < characters" do
        input = %{<div> this <<</div>}
        expected = %{<div> this &lt;&lt;</div>}
        actual = Loofah.scrub_fragment(input, :escape)
        assert_equal(expected, actual.to_html)
      end

      it "handles &lt; entity" do
        input = %{<div> this &lt; that </div>}
        expected = input
        actual = Loofah.scrub_fragment(input, :escape)
        assert_equal(expected, actual.to_html)
      end
    end
  end
end
