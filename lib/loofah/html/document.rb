module Loofah
  module HTML # :nodoc:
    #
    #  Subclass of Nokogiri::HTML::Document.
    #
    #  See Loofah::ScrubBehavior and Loofah::TextBehavior for additional methods.
    #
    class Document < Nokogiri::HTML::Document
      include Loofah::ScrubBehavior::Node
      include Loofah::DocumentDecorator
      include Loofah::TextBehavior
      include Loofah::StateRestore

      def serialize_root
        at_xpath("/html/body")
      end
    end
  end
end
