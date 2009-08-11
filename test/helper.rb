require 'test/unit'
require 'rubygems'
require 'mocha'
require 'shoulda'
require 'acts_as_fu'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "loofah"))

puts "=> testing with Nokogiri #{Nokogiri::VERSION_INFO.inspect}"
