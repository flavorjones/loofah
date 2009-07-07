module Dryopteris
  module HTML
    class DocumentFragment < Nokogiri::HTML::DocumentFragment
      include Dryopteris::SanitizerInstanceMethods

      class << self
        def parse tags
          self.new(Dryopteris::HTML::Document.new, tags)
        end
      end

      private

      def __sanitize_roots
        self.children
        maybe = xpath("./body").first
        if maybe
          maybe.children
        else
          self.children
        end
      end

    end
  end
end
