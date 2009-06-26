module Dryopteris
  module HTML
    class Document < Nokogiri::HTML::Document
      include Dryopteris::Sanitizer

      def __sanitize_root
        xpath("/html/body").first
      end

    end
  end
end
