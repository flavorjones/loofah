# frozen_string_literal: true

module Loofah
  module HTML4 # :nodoc:
    #
    #  Subclass of Nokogiri::HTML4::Document.
    #
    #  See Loofah::ScrubBehavior and Loofah::TextBehavior for additional methods.
    #
    class Document < Nokogiri::HTML4::Document
      include Loofah::ScrubBehavior::Node
      include Loofah::DocumentDecorator
      include Loofah::TextBehavior
      include Loofah::HtmlDocumentBehavior

      module NokogiriExtender
        def acts_as_loofah
          super
          singleton_class.include(Loofah::TextBehavior)
          singleton_class.include(Loofah::HtmlDocumentBehavior)
        end
      end
    end
  end
end

Nokogiri::HTML4::Document.include(Loofah::HTML4::Document::NokogiriExtender)
