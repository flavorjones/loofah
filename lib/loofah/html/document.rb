module Loofah
  module HTML
    #
    #  Subclass of Nokogiri::HTML::Document.
    #
    #  See Loofah::InstanceMethods for additional methods.
    #
    class Document < Nokogiri::HTML::Document
      include Loofah::InstanceMethods

      private

      def sanitize_roots # :nodoc:
        xpath("/html/head","/html/body")
      end

    end
  end
end
