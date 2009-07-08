$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
gem     'nokogiri', '>=1.3.0'
require 'nokogiri'

require 'dryopteris/html5'
require 'dryopteris/sanitize'
require 'dryopteris/html'

require 'dryopteris/deprecated'

module Dryopteris
  VERSION = '0.2.0'

  class << self
    def document(*args, &block)
      Dryopteris::HTML::Document.parse(*args, &block)
    end

    def fragment(*args, &block)
      Dryopteris::HTML::DocumentFragment.parse(*args, &block)
    end
  end

end
