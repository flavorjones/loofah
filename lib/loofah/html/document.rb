module Loofah
  module HTML
    #
    #  Subclass of Nokogiri::HTML::Document.
    #
    #  See Loofah::ScrubberInstanceMethods for additional methods.
    #
    class Document < Nokogiri::HTML::Document
      include Loofah::ScrubberInstanceMethods

      private

      def sanitize_roots # :nodoc:
        xpath("/html/head","/html/body")
      end

    end
  end
end
