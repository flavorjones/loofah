# frozen_string_literal: true

module Loofah
  module XML # :nodoc:
    #
    #  Subclass of Nokogiri::XML::DocumentFragment.
    #
    #  See Loofah::ScrubBehavior for additional methods.
    #
    class DocumentFragment < Nokogiri::XML::DocumentFragment
      class << self
        def parse(tags)
          doc = Loofah::XML::Document.new
          doc.encoding = tags.encoding.name if tags.respond_to?(:encoding)
          new(doc, tags)
        end
      end

      module NokogiriExtender
        def acts_as_loofah
          document.acts_as_loofah
          decorate_existing
        end

        # TODO: this should to be upstreamed into Nokogiri
        def decorate_existing # :nodoc:
          return unless Nokogiri.jruby?
          return unless document.instance_variable_get(:@decorators)

          traverse { |node| document.decorate(node) }
        end
      end
    end
  end
end

Nokogiri::XML::DocumentFragment.include(Loofah::XML::DocumentFragment::NokogiriExtender)
