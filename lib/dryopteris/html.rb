require 'dryopteris/html/document'
require 'dryopteris/html/document_fragment'

module Dryopteris
  module HTML
    class << self
      def Document(*args, &block)
        Dryopteris::HTML::Document.parse *args, &block
      end

      def DocumentFragment(*args, &block)
        Dryopteris::HTML::DocumentFragment.parse *args, &block
      end
    end
  end
end
