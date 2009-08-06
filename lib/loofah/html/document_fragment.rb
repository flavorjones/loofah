module Loofah
  module HTML
    class DocumentFragment < Nokogiri::HTML::DocumentFragment
      include Loofah::ScrubberInstanceMethods

      class << self
        def parse tags
          self.new(Loofah::HTML::Document.new, tags)
        end
      end

      private

      def __sanitize_roots
        xpath("./body").first || self
      end

    end
  end
end
