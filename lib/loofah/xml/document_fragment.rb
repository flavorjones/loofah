# frozen_string_literal: true

module Loofah
  module XML # :nodoc:
    #
    #  Subclass of Nokogiri::XML::DocumentFragment.
    #
    #  See Loofah::ScrubBehavior for additional methods.
    #
    class DocumentFragment < Nokogiri::XML::Document
      include Loofah::ScrubBehavior::Node
      include Loofah::DocumentDecorator

      class << self
        #
        #  Overridden Nokogiri::XML::Document
        #  constructor. Applications should use Loofah.fragment to
        #  parse a fragment.
        #
        def parse(tags)
          doc = Loofah::XML::Document.new
          doc.encoding = tags.encoding.name if tags.respond_to?(:encoding)
          new(doc, tags)
        end
      end
    end
  end
end
