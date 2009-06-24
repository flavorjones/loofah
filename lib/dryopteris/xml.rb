require 'dryopteris/xml/document'
require 'dryopteris/xml/document_fragment'

module Dryopteris
  module XML
    class << self
      def Document(*args, &block)
        Dryopteris::XML::Document.parse *args, &block
      end

      def DocumentFragment(*args, &block)
        Dryopteris::XML::DocumentFragment.parse *args, &block
      end
    end
  end
end
