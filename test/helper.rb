require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "dryopteris"))

if defined? Nokogiri::VERSION_INFO
  puts "=> running with Nokogiri #{Nokogiri::VERSION_INFO.inspect}"
else
  puts "=> running with Nokogiri #{Nokogiri::VERSION} / libxml #{Nokogiri::LIBXML_PARSER_VERSION}"
end
