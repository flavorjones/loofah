require "minitest/autorun"
require "minitest/unit"
require "minitest/spec"
require "rr"

require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "loofah"))

# require the ActionView helpers here, since they are no longer required automatically
require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "loofah", "helpers"))

puts "=> testing with Nokogiri #{Nokogiri::VERSION_INFO.inspect}"
puts "=> parser module is #{::Loofah::parser_module}"

class Loofah::TestCase < MiniTest::Spec
  class << self
    alias_method :context, :describe
  end

  def html5_mode?
    ::Loofah.html5_mode?
  end
end
