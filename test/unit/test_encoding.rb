# :coding: utf-8
# frozen_String_literal: true

require 'helper'

class UnitTestEncoding < Loofah::TestCase
  UTF8_STRING = '日本語'

  if ''.respond_to?(:encoding)
    describe 'scrub_fragment' do
      it 'sets the encoding for html' do
        escaped = Loofah.scrub_fragment(UTF8_STRING, :escape).to_s
        assert_equal UTF8_STRING.encoding, escaped.encoding
      end

      it 'sets the encoding for xml' do
        escaped = Loofah.scrub_xml_fragment(UTF8_STRING, :escape).to_s
        assert_equal UTF8_STRING.encoding, escaped.encoding
      end
    end
  end
end
