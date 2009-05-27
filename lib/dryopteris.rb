$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
gem     'nokogiri', '>=1.2.4'
require 'nokogiri'

require "dryopteris/whitelist"
require "dryopteris/sanitize"

module Dryopteris
  VERSION = '0.1'
end
