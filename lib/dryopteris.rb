$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
gem     'nokogiri', '>=1.3.0'
require 'nokogiri'

require 'dryopteris/html5'
require 'dryopteris/sanitize'
require 'dryopteris/html'

module Dryopteris
  VERSION = '0.2.0'
end
