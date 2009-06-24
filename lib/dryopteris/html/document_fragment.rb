module Dryopteris
  module HTML
    class DocumentFragment < Nokogiri::HTML::DocumentFragment

      class << self
        def parse tags
          self.new(Dryopteris::HTML::Document.new, tags)
        end
      end

    end
  end
end
