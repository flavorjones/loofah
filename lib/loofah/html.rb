require 'loofah/html/document'
require 'loofah/html/document_fragment'

module Loofah
  class << self
    # Shortcut for Loofah::HTML::Document.parse
    def document(*args, &block)
      Loofah::HTML::Document.parse(*args, &block)
    end

    # Shortcut for Loofah::HTML::DocumentFragment.parse
    def fragment(*args, &block)
      Loofah::HTML::DocumentFragment.parse(*args, &block)
    end
  end
end
