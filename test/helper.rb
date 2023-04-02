require "minitest/autorun"
require "minitest/unit"
require "minitest/spec"

require_relative "../lib/loofah"
require_relative "../lib/loofah/helpers"

puts "=> testing with Nokogiri #{Nokogiri::VERSION_INFO.inspect}"

class Loofah::TestCase < MiniTest::Spec
  class << self
    alias_method :context, :describe
  end

  LOOFAH_HTML_DOCUMENT_CLASSES = if Loofah.html5_support?
    [Loofah::HTML4::Document, Loofah::HTML5::Document]
  else
    [Loofah::HTML4::Document]
  end

  LOOFAH_HTML_DOCUMENT_FRAGMENT_CLASSES = if Loofah.html5_support?
    [Loofah::HTML4::DocumentFragment, Loofah::HTML5::DocumentFragment]
  else
    [Loofah::HTML4::DocumentFragment]
  end

  LOOFAH_HTML_VERSIONS = if Loofah.html5_support?
    [:html4, :html5]
  else
    [:html4]
  end
end
