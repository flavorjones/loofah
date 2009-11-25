module Loofah
  module HTML # :nodoc:
    #
    #  Subclass of Nokogiri::HTML::Document.
    #
    #  See Loofah::ScrubBehavior and Loofah::DocumentDecorator for additional methods.
    #
    class Document < Nokogiri::HTML::Document
      include Loofah::ScrubBehavior
      include Loofah::DocumentDecorator

      #
      #  Returns a plain-text version of the markup contained by the document
      #
      def text
        xpath("/html/body").inner_text
      end
      alias :inner_text :text
      alias :to_str     :text
    end
  end
end
