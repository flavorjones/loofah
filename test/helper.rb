require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'acts_as_fu'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "loofah"))

puts "=> testing with Nokogiri #{Nokogiri::VERSION_INFO.inspect}"
