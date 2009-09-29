module Loofah
  module Rails
    class << self
      #
      #  A replacement for Rails's built-in +strip_tags+ helper.
      #
      #   Loofah::Rails.strip_tags("<div>Hello <b>there</b></div>") # => "Hello there"
      #
      def strip_tags(string_or_io)
        Loofah.scrub_fragment(string_or_io, :prune).text
      end

      #
      #  A replacement for Rails's built-in +sanitize+ helper.
      #
      #   Loofah::Rails.sanitize("<script src=http://ha.ckers.org/xss.js></script>") # => "&lt;script src=\"http://ha.ckers.org/xss.js\"&gt;&lt;/script&gt;"
      #
      def sanitize(string_or_io)
        Loofah.scrub_fragment(string_or_io, :escape).to_s
      end
    end
  end
end
