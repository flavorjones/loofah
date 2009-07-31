module Loofah
  module HTML
    class Document < Nokogiri::HTML::Document
      include Loofah::SanitizerInstanceMethods

      private

      def __sanitize_roots
        xpath("/html/head","/html/body")
      end

    end
  end
end
