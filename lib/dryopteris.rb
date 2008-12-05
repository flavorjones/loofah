$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require "dryopteris/sanitize"

module Dryopteris
  VERSION = '0.1'
end