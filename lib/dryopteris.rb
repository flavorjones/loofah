
require 'rubygems'
gem 'nokogiri', '>=1.05'
require 'nokogiri'

require File.join(File.dirname(__FILE__), 'whitelist')

module Dryopteris

  def self.sanitize(string_or_io)
    doc = Nokogiri(string_or_io)
  end

end
