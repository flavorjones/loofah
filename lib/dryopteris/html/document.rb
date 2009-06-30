module Dryopteris
  module HTML
    class Document < Nokogiri::HTML::Document
      include Dryopteris::Sanitizer

      def __sanitize_roots
        xpath("/html/head/*","/html/body/*")
      end

    end
  end
end
