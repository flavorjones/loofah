require "minitest/autorun"
require "minitest/unit"
require "minitest/spec"

require_relative "../lib/loofah"
require_relative "../lib/loofah/helpers"

puts "=> testing with Nokogiri #{Nokogiri::VERSION_INFO.inspect}"

class Loofah::TestCase < MiniTest::Spec
  class << self
    alias_method :context, :describe
  end
end
