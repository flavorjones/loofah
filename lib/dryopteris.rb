
require 'rubygems'
gem 'nokogiri', '>=1.0.5'
require 'nokogiri'

require File.join(File.dirname(__FILE__), 'whitelist')

module Dryopteris

  def self.sanitize(string_or_io, encoding=nil)
    parser = Nokogiri::HTML::SAX::Parser.new(Dryopteris::Document.new)
    args = [string_or_io]
    args << encoding unless encoding.nil?
    parser.parse_memory(*args)
  end

  class Document < Nokogiri::XML::SAX::Document
    def start_element name, attrs = []
      puts "found element: #{name}"
    end
  end

end
