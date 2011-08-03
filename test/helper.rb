require 'rubygems'
require 'rr'
require 'minitest/unit'
require 'minitest/spec'
require 'minitest/autorun'

require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "loofah"))

puts "=> testing with Nokogiri #{Nokogiri::VERSION_INFO.inspect}"

class Loofah::TestCase < MiniTest::Spec
  include RR::Adapters::TestUnit

  class << self
    alias_method :context, :describe
  end
end
