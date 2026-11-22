# frozen_string_literal: true

require "helper"

# A non-main Ractor can read a constant only when its value is shareable, and
# cannot write a class's instance variables at all. The safelists in
# Loofah::HTML5::SafeList are left out on purpose: applications add to them
# at boot, so making them shareable is the application's call.
class UnitTestRactor < Loofah::TestCase
  before do
    skip("needs Ractor.shareable?") unless defined?(Ractor) && Ractor.respond_to?(:shareable?)
  end

  it "makes the constants Loofah reads while scrubbing shareable" do
    {
      "Loofah::Scrubbers::MAP" => Loofah::Scrubbers::MAP,
      "Loofah::HTML5::Scrub::CRASS_SEMICOLON" => Loofah::HTML5::Scrub::CRASS_SEMICOLON,
      "Loofah::HTML5::Scrub.singleton_class::TABLE_FOR_ESCAPE_HTML__" =>
        Loofah::HTML5::Scrub.singleton_class::TABLE_FOR_ESCAPE_HTML__,
      "Loofah::LibxmlWorkarounds::BROKEN_ESCAPING_ATTRIBUTES" => Loofah::LibxmlWorkarounds::BROKEN_ESCAPING_ATTRIBUTES,
      "Loofah::LibxmlWorkarounds::BROKEN_ESCAPING_ATTRIBUTES_QUALIFYING_TAG" =>
        Loofah::LibxmlWorkarounds::BROKEN_ESCAPING_ATTRIBUTES_QUALIFYING_TAG,
    }.merge(Loofah::Elements.constants.to_h { |name| ["Loofah::Elements::#{name}", Loofah::Elements.const_get(name)] })
      .each { |name, value| assert(Ractor.shareable?(value), "#{name} (#{value.class}) is not shareable") }
  end

  it "parses a fragment without writing to the fragment class" do
    LOOFAH_HTML_DOCUMENT_FRAGMENT_CLASSES.each do |klass|
      klass.parse("<p>hello</p>")

      refute(klass.instance_variable_defined?(:@document_klass), "#{klass} memoized @document_klass")
    end
  end
end
