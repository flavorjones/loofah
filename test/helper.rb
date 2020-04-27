# frozen_string_literal: true

require 'rubygems'
require 'minitest/unit'
require 'minitest/spec'
require 'minitest/autorun'
require 'rr'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'loofah'))

# require the ActionView helpers here, since they are no longer required automatically
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'loofah', 'helpers'))

puts "=> testing with Nokogiri #{Nokogiri::VERSION_INFO.inspect}"

module Loofah
  class TestCase < MiniTest::Spec
    class << self
      alias context describe
    end
  end
end
