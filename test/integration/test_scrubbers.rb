# frozen_string_literal: true

require "helper"

class IntegrationTestScrubbers < Loofah::TestCase
  INVALID_FRAGMENT = "<invalid>foo<p>bar</p>bazz</invalid><div>quux</div>"
  INVALID_ESCAPED = "&lt;invalid&gt;foo&lt;p&gt;bar&lt;/p&gt;bazz&lt;/invalid&gt;<div>quux</div>"
  INVALID_PRUNED = "<div>quux</div>"
  INVALID_STRIPPED = "foo<p>bar</p>bazz<div>quux</div>"

  WHITEWASH_FRAGMENT = "<o:div>no</o:div><div id='no'>foo</div><invalid>bar</invalid><!--[if gts mso9]><div>microsofty stuff</div><![endif]-->"
  WHITEWASH_RESULT = "<div>foo</div>"
  WHITEWASH_RESULT_LIBXML2911 = "<div>no</div>\n<div>foo</div>"
  WHITEWASH_RESULT_JRUBY = "<o:div>no</o:div><div>foo</div>"

  NOFOLLOW_FRAGMENT = '<a href="http://www.example.com/">Click here</a>'
  NOFOLLOW_RESULT = '<a href="http://www.example.com/" rel="nofollow">Click here</a>'

  TARGET_FRAGMENT = '<a href="http://www.example.com/">Click here</a>'
  TARGET_RESULT = '<a href="http://www.example.com/" target="_blank">Click here</a>'

  ANCHOR_TARGET_FRAGMENT = '<a href="#top">Click here</a>'
  ANCHOR_TARGET_RESULT = '<a href="#top">Click here</a>'

  TARGET_WITH_TOP_FRAGMENT = '<a href="http://www.example.com/" target="_top">Click here</a>'
  TARGET_WITH_TOP_RESULT = '<a href="http://www.example.com/" target="_blank">Click here</a>'

  NOFOLLOW_WITH_REL_FRAGMENT = '<a href="http://www.example.com/" rel="noopener">Click here</a>'
  NOFOLLOW_WITH_REL_RESULT = '<a href="http://www.example.com/" rel="noopener nofollow">Click here</a>'

  NOOPENER_FRAGMENT = '<a href="http://www.example.com/">Click here</a>'
  NOOPENER_RESULT = '<a href="http://www.example.com/" rel="noopener">Click here</a>'

  NOOPENER_WITH_REL_FRAGMENT = '<a href="http://www.example.com/" rel="nofollow">Click here</a>'
  NOOPENER_WITH_REL_RESULT = '<a href="http://www.example.com/" rel="nofollow noopener">Click here</a>'

  NOREFERRER_FRAGMENT = '<a href="http://www.example.com/">Click here</a>'
  NOREFERRER_RESULT = '<a href="http://www.example.com/" rel="noreferrer">Click here</a>'

  NOREFERRER_WITH_REL_FRAGMENT = '<a href="http://www.example.com/" rel="noopener">Click here</a>'
  NOREFERRER_WITH_REL_RESULT = '<a href="http://www.example.com/" rel="noopener noreferrer">Click here</a>'

  UNPRINTABLE_FRAGMENT = "<b>Lo\u2029ofah ro\u2028cks!</b><script>x\u2028y</script>"
  UNPRINTABLE_RESULT = "<b>Loofah rocks!</b><script>xy</script>"

  ENTITY_FRAGMENT = "<p>this is &lt; that &quot;&amp;&quot; the other &gt; boo&apos;ya</p><div>w00t</div>"
  ENTITY_TEXT = %(this is < that "&" the other > boo'yaw00t)

  ENTITY_HACK_ATTACK = "<div><div>Hack attack!</div><div>&lt;script&gt;alert('evil')&lt;/script&gt;</div></div>"
  ENTITY_HACK_ATTACK_TEXT_SCRUB = "Hack attack!&lt;script&gt;alert('evil')&lt;/script&gt;"
  ENTITY_HACK_ATTACK_TEXT_SCRUB_UNESC = "Hack attack!<script>alert('evil')</script>"

  BREAKPOINT_FRAGMENT = "<p>Some text here in a logical paragraph.<br><br>Some more text, apparently a second paragraph.<br><br>Et cetera...</p>"
  BREAKPOINT_RESULT = "<p>Some text here in a logical paragraph.</p><p>Some more text, apparently a second paragraph.</p><p>Et cetera...</p>"

  context "scrubbing shortcuts" do
    context "#scrub_document" do
      it "is a shortcut for parse-and-scrub" do
        mock_doc = MiniTest::Mock.new
        mock_doc.expect(:scrub!, "sanitized_string", [:method])

        Loofah::HTML4::Document.stub(:parse, mock_doc) do
          Loofah.scrub_document("string", :method)
        end

        mock_doc.verify
      end
    end

    context "#scrub_html4_document" do
      it "is a shortcut for parse-and-scrub" do
        mock_doc = MiniTest::Mock.new
        mock_doc.expect(:scrub!, "sanitized_string", [:method])

        Loofah::HTML4::Document.stub(:parse, mock_doc) do
          Loofah.scrub_html4_document("string", :method)
        end

        mock_doc.verify
      end
    end

    context "#scrub_html5_document" do
      it "is a shortcut for parse-and-scrub" do
        mock_doc = MiniTest::Mock.new
        mock_doc.expect(:scrub!, "sanitized_string", [:method])

        Loofah::HTML5::Document.stub(:parse, mock_doc) do
          Loofah.scrub_html5_document("string", :method)
        end

        mock_doc.verify
      end
    end if Loofah.html5_support?

    context "#scrub_fragment" do
      it "is a shortcut for parse-and-scrub" do
        mock_doc = MiniTest::Mock.new
        mock_doc.expect(:scrub!, "sanitized_string", [:method])

        Loofah::HTML4::DocumentFragment.stub(:parse, mock_doc) do
          Loofah.scrub_fragment("string", :method)
        end

        mock_doc.verify
      end
    end

    context "#scrub_html4_fragment" do
      it "is a shortcut for parse-and-scrub" do
        mock_doc = MiniTest::Mock.new
        mock_doc.expect(:scrub!, "sanitized_string", [:method])

        Loofah::HTML4::DocumentFragment.stub(:parse, mock_doc) do
          Loofah.scrub_html4_fragment("string", :method)
        end

        mock_doc.verify
      end
    end

    context "#scrub_html5_fragment" do
      it "is a shortcut for parse-and-scrub" do
        mock_doc = MiniTest::Mock.new
        mock_doc.expect(:scrub!, "sanitized_string", [:method])

        Loofah::HTML5::DocumentFragment.stub(:parse, mock_doc) do
          Loofah.scrub_html5_fragment("string", :method)
        end

        mock_doc.verify
      end
    end if Loofah.html5_support?
  end

  LOOFAH_HTML_DOCUMENT_CLASSES.each do |klass|
    context klass do
      let(:klass) { klass }

      def html5?
        klass.to_s == "Loofah::HTML5::Document"
      end

      context "#scrub!" do
        context ":escape" do
          it "escape bad tags" do
            doc = klass.parse("<html><body>#{INVALID_FRAGMENT}</body></html>")
            result = doc.scrub!(:escape)

            assert_equal INVALID_ESCAPED, doc.xpath("/html/body").inner_html
            assert_equal doc, result
          end
        end

        context ":prune" do
          it "prune bad tags" do
            doc = klass.parse("<html><body>#{INVALID_FRAGMENT}</body></html>")
            result = doc.scrub!(:prune)

            assert_equal INVALID_PRUNED, doc.xpath("/html/body").inner_html
            assert_equal doc, result
          end
        end

        context ":strip" do
          it "strip bad tags" do
            doc = klass.parse("<html><body>#{INVALID_FRAGMENT}</body></html>")
            result = doc.scrub!(:strip)

            assert_equal INVALID_STRIPPED, doc.xpath("/html/body").inner_html
            assert_equal doc, result
          end
        end

        context ":whitewash" do
          it "whitewash the markup" do
            doc = klass.parse("<html><body>#{WHITEWASH_FRAGMENT}</body></html>")
            result = doc.scrub!(:whitewash)

            ww_result = if Nokogiri.uses_libxml?("<2.9.11") || Nokogiri.uses_libxml?(">=2.10.4") || html5?
              WHITEWASH_RESULT
            elsif Nokogiri.jruby?
              WHITEWASH_RESULT_JRUBY
            else
              WHITEWASH_RESULT_LIBXML2911
            end

            assert_equal ww_result, doc.xpath("/html/body").inner_html
            assert_equal doc, result
          end
        end

        context ":nofollow" do
          it "add a 'nofollow' attribute to hyperlinks" do
            doc = klass.parse("<html><body>#{NOFOLLOW_FRAGMENT}</body></html>")
            result = doc.scrub!(:nofollow)

            assert_equal NOFOLLOW_RESULT, doc.xpath("/html/body").inner_html
            assert_equal doc, result
          end
        end

        context ":targetblank" do
          context "when target is not set" do
            it "adds a target='_blank' attribute to hyperlinks" do
              doc = klass.parse("<html><body>#{TARGET_FRAGMENT}</body></html>")
              result = doc.scrub!(:targetblank)

              assert_equal TARGET_RESULT, doc.xpath("/html/body").inner_html
              assert_equal doc, result
            end

            it "skips target attribute when linking to anchor" do
              doc = klass.parse("<html><body>#{ANCHOR_TARGET_FRAGMENT}</body></html>")
              result = doc.scrub!(:targetblank)

              assert_equal ANCHOR_TARGET_RESULT, doc.xpath("/html/body").inner_html
              assert_equal doc, result
            end
          end

          context "when target is set" do
            it "replaces existing 'target' attribute with '_blank' to hyperlinks" do
              doc = klass.parse("<html><body>#{TARGET_WITH_TOP_FRAGMENT}</body></html>")
              result = doc.scrub!(:targetblank)

              assert_equal TARGET_WITH_TOP_RESULT, doc.xpath("/html/body").inner_html
              assert_equal doc, result
            end
          end
        end

        context ":unprintable" do
          it "removes unprintable unicode characters" do
            doc = klass.parse("<html><body>#{UNPRINTABLE_FRAGMENT}</body></html>")
            result = doc.scrub!(:unprintable)

            assert_equal UNPRINTABLE_RESULT, doc.xpath("/html/body").inner_html
            assert_equal doc, result
          end
        end

        context ":double_breakpoint" do
          it "replaces double line breaks with paragraph tags" do
            doc = klass.parse("<html><body>#{BREAKPOINT_FRAGMENT}</body></html>")
            result = doc.scrub!(:double_breakpoint)

            assert_equal BREAKPOINT_RESULT, doc.xpath("/html/body").inner_html.delete("\n")
            assert_equal doc, result
          end
        end
      end

      context "#text" do
        it "leave behind only inner text with html entities still escaped" do
          doc = klass.parse("<html><body>#{ENTITY_HACK_ATTACK}</body></html>")
          result = doc.text

          assert_equal ENTITY_HACK_ATTACK_TEXT_SCRUB, result
        end

        context "with encode_special_chars => false" do
          it "leave behind only inner text with html entities unescaped" do
            doc = klass.parse("<html><body>#{ENTITY_HACK_ATTACK}</body></html>")
            result = doc.text(encode_special_chars: false)

            assert_equal ENTITY_HACK_ATTACK_TEXT_SCRUB_UNESC, result
          end
        end

        context "with encode_special_chars => true" do
          it "leave behind only inner text with html entities still escaped" do
            doc = klass.parse("<html><body>#{ENTITY_HACK_ATTACK}</body></html>")
            result = doc.text(encode_special_chars: true)

            assert_equal ENTITY_HACK_ATTACK_TEXT_SCRUB, result
          end
        end
      end

      context "#to_s" do
        it "generate HTML" do
          doc = klass.parse("<html><head><title>quux</title></head><body><div>foo</div></body></html>")
          string = doc.to_s

          refute_nil doc.xpath("/html").first
          refute_nil doc.xpath("/html/head").first
          refute_nil doc.xpath("/html/body").first

          if html5? || Nokogiri.jruby?
            refute_match(/<!DOCTYPE/, string)
          else
            assert_match(/<!DOCTYPE/, string)
          end

          assert_match(/<html>/, string)
          assert_match(/<head>/, string)
          assert_match(/<body>/, string)
        end
      end

      context "#serialize" do
        it "generate HTML" do
          doc = klass.parse("<html><head><title>quux</title></head><body><div>foo</div></body></html>")
          string = doc.serialize

          refute_nil doc.xpath("/html").first
          refute_nil doc.xpath("/html/head").first
          refute_nil doc.xpath("/html/body").first

          if html5? || Nokogiri.jruby?
            refute_match(/<!DOCTYPE/, string)
          else
            assert_match(/<!DOCTYPE/, string)
          end

          assert_match(/<html>/, string)
          assert_match(/<head>/, string)
          assert_match(/<body>/, string)
        end
      end

      context "Node" do
        context "#scrub!" do
          it "only scrub subtree" do
            xml = klass.parse(<<~HTML)
              <html><body>
                <div class='scrub'>
                  <script>I should be removed</script>
                </div>
                <div class='noscrub'>
                  <script>I should remain</script>
                </div>
              </body></html>
            HTML
            node = xml.at_css("div.scrub")
            node.scrub!(:prune)

            assert_match(/I should remain/, xml.to_s)
            refute_match(/I should be removed/, xml.to_s)
          end
        end
      end

      context "NodeSet" do
        context "#scrub!" do
          it "only scrub subtrees" do
            xml = klass.parse(<<~HTML)
              <html><body>
                <div class='scrub'>
                  <script>I should be removed</script>
                </div>
                <div class='noscrub'>
                  <script>I should remain</script>
                </div>
                <div class='scrub'>
                  <script>I should also be removed</script>
                </div>
              </body></html>
            HTML
            node_set = xml.css("div.scrub")

            assert_equal 2, node_set.length
            node_set.scrub!(:prune)

            assert_match(/I should remain/, xml.to_s)
            refute_match(/I should be removed/, xml.to_s)
            refute_match(/I should also be removed/, xml.to_s)
          end
        end
      end
    end
  end

  LOOFAH_HTML_DOCUMENT_FRAGMENT_CLASSES.each do |klass|
    context klass do
      let(:klass) { klass }

      def html5?
        klass.to_s == "Loofah::HTML5::DocumentFragment"
      end

      context "#scrub!" do
        context ":escape" do
          it "escape bad tags" do
            doc = klass.parse("<div>#{INVALID_FRAGMENT}</div>")
            result = doc.scrub!(:escape)

            assert_equal INVALID_ESCAPED, doc.xpath("./div").inner_html
            assert_equal doc, result
          end
        end

        context ":prune" do
          it "prune bad tags" do
            doc = klass.parse("<div>#{INVALID_FRAGMENT}</div>")
            result = doc.scrub!(:prune)

            assert_equal INVALID_PRUNED, doc.xpath("./div").inner_html
            assert_equal doc, result
          end
        end

        context ":strip" do
          it "strip bad tags" do
            doc = klass.parse("<div>#{INVALID_FRAGMENT}</div>")
            result = doc.scrub!(:strip)

            assert_equal INVALID_STRIPPED, doc.xpath("./div").inner_html
            assert_equal doc, result
          end
        end

        context ":whitewash" do
          it "whitewash the markup" do
            doc = klass.parse("<div>#{WHITEWASH_FRAGMENT}</div>")
            result = doc.scrub!(:whitewash)

            ww_result = if Nokogiri.uses_libxml?("<2.9.11") || Nokogiri.uses_libxml?(">=2.10.4") || html5?
              WHITEWASH_RESULT
            elsif Nokogiri.jruby?
              WHITEWASH_RESULT_JRUBY
            else
              WHITEWASH_RESULT_LIBXML2911
            end

            assert_equal ww_result, doc.xpath("./div").inner_html
            assert_equal doc, result
          end
        end

        context ":nofollow" do
          context "for a hyperlink that does not have a rel attribute" do
            it "add a 'nofollow' attribute to hyperlinks" do
              doc = klass.parse("<div>#{NOFOLLOW_FRAGMENT}</div>")
              result = doc.scrub!(:nofollow)

              assert_equal NOFOLLOW_RESULT, doc.xpath("./div").inner_html
              assert_equal doc, result
            end
          end

          context "for a hyperlink that does have a rel attribute" do
            it "appends nofollow to rel attribute" do
              doc = klass.parse("<div>#{NOFOLLOW_WITH_REL_FRAGMENT}</div>")
              result = doc.scrub!(:nofollow)

              assert_equal NOFOLLOW_WITH_REL_RESULT, doc.xpath("./div").inner_html
              assert_equal doc, result
            end
          end
        end

        context ":noopener" do
          context "for a hyperlink without a 'rel' attribute" do
            it "add a 'noopener' attribute to hyperlinks" do
              doc = klass.parse("<div>#{NOOPENER_FRAGMENT}</div>")
              result = doc.scrub!(:noopener)

              assert_equal NOOPENER_RESULT, doc.xpath("./div").inner_html
              assert_equal doc, result
            end
          end

          context "for a hyperlink that does have a rel attribute" do
            it "appends 'noopener' to 'rel' attribute" do
              doc = klass.parse("<div>#{NOOPENER_WITH_REL_FRAGMENT}</div>")
              result = doc.scrub!(:noopener)

              assert_equal NOOPENER_WITH_REL_RESULT, doc.xpath("./div").inner_html
              assert_equal doc, result
            end
          end
        end

        context ":noreferrer" do
          context "for a hyperlink without a 'rel' attribute" do
            it "add a 'noreferrer' attribute to hyperlinks" do
              doc = klass.parse("<div>#{NOREFERRER_FRAGMENT}</div>")
              result = doc.scrub!(:noreferrer)

              assert_equal NOREFERRER_RESULT, doc.xpath("./div").inner_html
              assert_equal doc, result
            end
          end

          context "for a hyperlink that does have a rel attribute" do
            it "appends 'noreferrer' to 'rel' attribute" do
              doc = klass.parse("<div>#{NOREFERRER_WITH_REL_FRAGMENT}</div>")
              result = doc.scrub!(:noreferrer)

              assert_equal NOREFERRER_WITH_REL_RESULT, doc.xpath("./div").inner_html
              assert_equal doc, result
            end
          end
        end

        context ":unprintable" do
          it "removes unprintable unicode characters" do
            doc = klass.parse("<div>#{UNPRINTABLE_FRAGMENT}</div>")
            result = doc.scrub!(:unprintable)

            assert_equal UNPRINTABLE_RESULT, doc.xpath("./div").inner_html
            assert_equal doc, result
          end
        end
      end

      context "#text" do
        it "leave behind only inner text with html entities still escaped" do
          doc = klass.parse("<div>#{ENTITY_HACK_ATTACK}</div>")
          result = doc.text

          assert_equal ENTITY_HACK_ATTACK_TEXT_SCRUB, result
        end

        context "with encode_special_chars => false" do
          it "leave behind only inner text with html entities unescaped" do
            doc = klass.parse("<div>#{ENTITY_HACK_ATTACK}</div>")
            result = doc.text(encode_special_chars: false)

            assert_equal ENTITY_HACK_ATTACK_TEXT_SCRUB_UNESC, result
          end
        end

        context "with encode_special_chars => true" do
          it "leave behind only inner text with html entities still escaped" do
            doc = klass.parse("<div>#{ENTITY_HACK_ATTACK}</div>")
            result = doc.text(encode_special_chars: true)

            assert_equal ENTITY_HACK_ATTACK_TEXT_SCRUB, result
          end
        end
      end

      context "#to_s" do
        it "not remove entities" do
          string = klass.parse(ENTITY_FRAGMENT).to_s

          assert_match(/this is &lt;/, string)
        end
      end

      context "Node" do
        context "#scrub!" do
          it "only scrub subtree" do
            xml = klass.parse(<<~HTML)
              <div class='scrub'>
                <script>I should be removed</script>
              </div>
              <div class='noscrub'>
                <script>I should remain</script>
              </div>
            HTML
            node = xml.at_css("div.scrub")
            node.scrub!(:prune)

            assert_match(/I should remain/, xml.to_s)
            refute_match(/I should be removed/, xml.to_s)
          end
        end
      end

      context "NodeSet" do
        context "#scrub!" do
          it "only scrub subtrees" do
            xml = klass.parse(<<~HTML)
              <div class='scrub'>
                <script>I should be removed</script>
              </div>
              <div class='noscrub'>
                <script>I should remain</script>
              </div>
              <div class='scrub'>
                <script>I should also be removed</script>
              </div>
            HTML
            node_set = xml.css("div.scrub")

            assert_equal 2, node_set.length

            node_set.scrub!(:prune)

            assert_match(/I should remain/, xml.to_s)
            refute_match(/I should be removed/, xml.to_s)
            refute_match(/I should also be removed/, xml.to_s)
          end
        end
      end
    end
  end
end
