require 'dryopteris/html/document'
require 'dryopteris/html/document_fragment'

module Dryopteris
  class << self
    # Shortcut for Dryopteris::HTML::Document.parse
    def document(*args, &block)
      Dryopteris::HTML::Document.parse(*args, &block)
    end

    # Shortcut for Dryopteris::HTML::DocumentFragment.parse
    def fragment(*args, &block)
      Dryopteris::HTML::DocumentFragment.parse(*args, &block)
    end
  end
end
