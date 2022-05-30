# frozen_string_literal: true
module Loofah
  module HTML # :nodoc:
    #
    #  Subclass of Nokogiri::HTML5::Document.
    #
    #  See Loofah::ScrubBehavior and Loofah::TextBehavior for additional methods.
    #
    class Document < ::Loofah.parser_module(:Document)
      include Loofah::ScrubBehavior::Node
      include Loofah::DocumentDecorator
      include Loofah::TextBehavior

      def serialize_root
        at_xpath("/html/body")
      end
    end
  end
end
