# frozen_string_literal: true

module Loofah
  module XML # :nodoc:
    #
    #  Subclass of Nokogiri::XML::Document.
    #
    #  See Loofah::ScrubBehavior for additional methods.
    #
    class Document < Nokogiri::XML::Document
      include Loofah::ScrubBehavior::Node
      include Loofah::DocumentDecorator

      module NokogiriExtender
        def acts_as_loofah
          singleton_class.include(Loofah::ScrubBehavior::Node)
          Loofah::DocumentDecorator.decorate(self)
          decorate_existing
        end

        # TODO: this should to be upstreamed into Nokogiri
        def decorate_existing # :nodoc:
          return unless @decorators

          if Nokogiri.jruby?
            traverse { |node| decorate(node) }
          else
            @node_cache.each { |node| decorate(node) }
          end
        end
      end
    end
  end
end

Nokogiri::XML::Document.include(Loofah::XML::Document::NokogiriExtender)
