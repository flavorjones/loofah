# frozen_string_literal: true

require "helper"

class UnitTestActsAsLoofah < Loofah::TestCase
  SUBJECTS = [Nokogiri::XML, Nokogiri::HTML4, defined?(Nokogiri::HTML5) && Nokogiri::HTML5].compact

  SUBJECTS.each do |subject|
    describe subject do
      it "Document act like Loofah" do
        ndoc = subject::Document.parse("<html><body><div>hello</div><span>hello</span><script>alert(1)</script></body></html>")
        node = ndoc.at_css("div")

        # method presence
        refute_respond_to(ndoc, :scrub!)
        refute_respond_to(node, :scrub!)

        ndoc.acts_as_loofah

        assert_respond_to(ndoc, :scrub!, "#{subject}::Document should be extended")
        assert_respond_to(ndoc.at_css("span"), :scrub!, "New child elements should be extended")
        assert_respond_to(node, :scrub!, "Existing child elements should be extended")

        refute_respond_to(subject::Document.parse("<div>"), :scrub!, "Other instances should not be extended")

        # scrub behavior
        ndoc.scrub!(:prune)

        refute_includes(ndoc.to_html, "script")

        # other concerns
        if subject.name.include?("HTML")
          assert_includes(ndoc.singleton_class.ancestors, Loofah::TextBehavior)
          assert_includes(ndoc.singleton_class.ancestors, Loofah::HtmlDocumentBehavior)
        end
      end

      it "DocumentFragment act like Loofah" do
        nfrag = subject::DocumentFragment.parse("<div>hello</div><span>hello</span><script>alert(1)</script>")
        node = nfrag.at_css("div")

        # method presence
        refute_respond_to(nfrag, :scrub!)
        refute_respond_to(node, :scrub!)

        nfrag.acts_as_loofah

        assert_respond_to(nfrag, :scrub!, "#{subject}::DocumentFragment should be extended")
        assert_respond_to(nfrag.at_css("span"), :scrub!, "New child elements should be extended")
        assert_respond_to(node, :scrub!, "Existing child elements should be extended")

        refute_respond_to(subject::DocumentFragment.parse("<div>"), :scrub!, "Other instances should not be extended")

        # scrub behavior
        nfrag.scrub!(:prune)

        refute_includes(nfrag.to_html, "script")

        # other concerns
        if subject.name.include?("HTML")
          assert_includes(nfrag.singleton_class.ancestors, Loofah::TextBehavior)
          assert_includes(nfrag.singleton_class.ancestors, Loofah::HtmlFragmentBehavior)
        end
      end
    end
  end
end
