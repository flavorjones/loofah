# :coding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helper'))

class TestEncoding < Test::Unit::TestCase
  def test_string_sets_encoding
    utf8_string = "日本語"
    escaped = Loofah.scrub_fragment(utf8_string, :escape).to_s
    assert_equal utf8_string.encoding, escaped.encoding
  end
end
