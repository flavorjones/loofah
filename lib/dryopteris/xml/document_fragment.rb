module Dryopteris
  module XML
    class DocumentFragment < Nokogiri::XML::DocumentFragment

      class << self
        def parse tags
          self.new(Dryopteris::XML::Document.new, tags)
        end
      end

    end
  end
end
