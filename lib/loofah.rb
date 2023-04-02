# frozen_string_literal: true
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require "nokogiri"

require_relative "loofah/version"
require_relative "loofah/metahelpers"
require_relative "loofah/elements"

require_relative "loofah/html5/safelist"
require_relative "loofah/html5/libxml2_workarounds"
require_relative "loofah/html5/scrub"

require_relative "loofah/scrubber"
require_relative "loofah/scrubbers"

require_relative "loofah/instance_methods"
require_relative "loofah/xml/document"
require_relative "loofah/xml/document_fragment"
require_relative "loofah/html4/document"
require_relative "loofah/html4/document_fragment"

# == Strings and IO Objects as Input
#
# The following methods accept any IO object in addition to accepting a string:
#
# - Loofah.html4_document
# - Loofah.html4_fragment
# - Loofah.xml_document
# - Loofah.xml_fragment
# - Loofah.scrub_html4_document
# - Loofah.scrub_html4_fragment
# - Loofah.scrub_xml_document
# - Loofah.scrub_xml_fragment
# - Loofah.document
# - Loofah.fragment
# - Loofah.scrub_document
# - Loofah.scrub_fragment
#
# That IO object could be a file, or a socket, or a StringIO, or anything that responds to +read+
# and +close+.
#
module Loofah
  # Alias for Loofah::HTML4
  HTML = HTML4

  class << self
    # Shortcut for Loofah::HTML4::Document.parse(*args, &block)
    #
    # This method accepts the same parameters as Nokogiri::HTML4::Document.parse
    def html4_document(*args, &block)
      Loofah::HTML4::Document.parse(*args, &block)
    end

    # Shortcut for Loofah::HTML4::DocumentFragment.parse(*args, &block)
    #
    # This method accepts the same parameters as Nokogiri::HTML4::DocumentFragment.parse
    def html4_fragment(*args, &block)
      Loofah::HTML4::DocumentFragment.parse(*args, &block)
    end

    # Shortcut for Loofah::HTML4::Document.parse(string_or_io).scrub!(method)
    def scrub_html4_document(string_or_io, method)
      Loofah::HTML4::Document.parse(string_or_io).scrub!(method)
    end

    # Shortcut for Loofah::HTML4::DocumentFragment.parse(string_or_io).scrub!(method)
    def scrub_html4_fragment(string_or_io, method)
      Loofah::HTML4::DocumentFragment.parse(string_or_io).scrub!(method)
    end

    alias_method :document, :html4_document
    alias_method :fragment, :html4_fragment
    alias_method :scrub_document, :scrub_html4_document
    alias_method :scrub_fragment, :scrub_html4_fragment

    # Shortcut for Loofah::XML::Document.parse(*args, &block)
    #
    # This method accepts the same parameters as Nokogiri::XML::Document.parse
    def xml_document(*args, &block)
      Loofah::XML::Document.parse(*args, &block)
    end

    # Shortcut for Loofah::XML::DocumentFragment.parse(*args, &block)
    #
    # This method accepts the same parameters as Nokogiri::XML::DocumentFragment.parse
    def xml_fragment(*args, &block)
      Loofah::XML::DocumentFragment.parse(*args, &block)
    end

    # Shortcut for Loofah.xml_fragment(string_or_io).scrub!(method)
    def scrub_xml_fragment(string_or_io, method)
      Loofah.xml_fragment(string_or_io).scrub!(method)
    end

    # Shortcut for Loofah.xml_document(string_or_io).scrub!(method)
    def scrub_xml_document(string_or_io, method)
      Loofah.xml_document(string_or_io).scrub!(method)
    end

    # A helper to remove extraneous whitespace from text-ified HTML
    def remove_extraneous_whitespace(string)
      string.gsub(/\n\s*\n\s*\n/, "\n\n")
    end
  end
end
