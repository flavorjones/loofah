module Dryopteris
  module HTML
    class DocumentFragment < Nokogiri::HTML::DocumentFragment
      include Dryopteris::Sanitizer

      class << self
        def parse tags
          self.new(Dryopteris::HTML::Document.new, tags)
        end
      end

      def __sanitize_root
        self
      end

    end
  end
end
