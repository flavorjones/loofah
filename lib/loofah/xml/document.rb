module Loofah
  module XML
    #
    #  Subclass of Nokogiri::XML::Document.
    #
    #  See Loofah::InstanceMethods for additional methods.
    #
    class Document < Nokogiri::XML::Document
      include Loofah::InstanceMethods

      private

      def sanitize_roots # :nodoc:
        self
      end

    end
  end
end
