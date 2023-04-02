# :coding: utf-8
# frozen_string_literal: true

require "helper"

class UnitTestEncoding < Loofah::TestCase
  UTF8_STRING = "日本語"

  if String.new.respond_to?(:encoding)
    describe "#scrub_html4_fragment" do
      it "sets the encoding for html" do
        escaped = Loofah.scrub_html4_fragment(UTF8_STRING, :escape).to_s

        assert_equal UTF8_STRING.encoding, escaped.encoding
      end
    end

    describe "#scrub_html5_fragment" do
      it "sets the encoding for html" do
        escaped = Loofah.scrub_html5_fragment(UTF8_STRING, :escape).to_s

        assert_equal UTF8_STRING.encoding, escaped.encoding
      end
    end if Loofah.html5_support?

    describe "#scrub_xml_fragment" do
      it "sets the encoding for xml" do
        escaped = Loofah.scrub_xml_fragment(UTF8_STRING, :escape).to_s

        assert_equal UTF8_STRING.encoding, escaped.encoding
      end
    end
  end
end
