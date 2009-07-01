module Dryopteris
  module HTML
    class DocumentFragment < Nokogiri::HTML::DocumentFragment
      include Dryopteris::Sanitizer

      class << self
        def parse tags
          self.new(Dryopteris::HTML::Document.new, tags)
        end
      end

      private

      def __sanitize_roots
        self.children
      end

    end
  end
end
