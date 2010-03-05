module Loofah
  module Helpers
    class << self
      #
      #  A replacement for Rails's built-in +strip_tags+ helper.
      #
      #   Loofah::Helpers.strip_tags("<div>Hello <b>there</b></div>") # => "Hello there"
      #
      def strip_tags(string_or_io)
        Loofah.fragment(string_or_io).text
      end

      #
      #  A replacement for Rails's built-in +sanitize+ helper.
      #
      #   Loofah::Helpers.sanitize("<script src=http://ha.ckers.org/xss.js></script>") # => "&lt;script src=\"http://ha.ckers.org/xss.js\"&gt;&lt;/script&gt;"
      #
      def sanitize(string_or_io)
        Loofah.scrub_fragment(string_or_io, :strip).to_s
      end

      #
      #  A helper to remove extraneous whitespace from text-ified HTML
      #
      def remove_extraneous_whitespace(string)
        string.gsub(/\n\s*\n\s*\n/,"\n\n")
      end
    end
  end
end
