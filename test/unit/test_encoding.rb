# :coding: utf-8
require "helper"

class UnitTestEncoding < Loofah::TestCase
  def setup
    @utf8_string = "日本語"
  end

  if String.new.respond_to?(:encoding)
    def test_html_fragment_string_sets_encoding
      escaped = Loofah.scrub_fragment(@utf8_string, :escape).to_s
      assert_equal @utf8_string.encoding, escaped.encoding
    end

    def test_xml_fragment_string_sets_encoding
      escaped = Loofah.scrub_xml_fragment(@utf8_string, :escape).to_s
      assert_equal @utf8_string.encoding, escaped.encoding
    end
  end
end
