module Loofah
  class << self
    def strip_tags(string_or_io) # :nodoc:
      warn_once "WARNING: Loofah.strip_tags is deprecated and will be removed in Loofah 0.3.0. Please switch to Loofah.scrub_document(string_or_io, :prune)"
      Loofah.scrub_document(string_or_io, :prune).text
    end
    
    def whitewash(string_or_io) # :nodoc:
      warn_once "WARNING: Loofah.whitewash is deprecated and will be removed in Loofah 0.3.0. Please switch to Loofah.scrub_fragment(string_or_io, :whitewash)"
      Loofah.scrub_fragment(string_or_io, :whitewash).to_s
    end

    def whitewash_document(string_or_io) # :nodoc:
      warn_once "WARNING: Loofah.whitewash_document is deprecated and will be removed in Loofah 0.3.0. Please switch to Loofah.scrub_document(string_or_io, :whitewash)"
      Loofah.scrub_document(string_or_io, :whitewash).to_s
    end

    def sanitize(string_or_io) # :nodoc:
      warn_once "WARNING: Loofah.sanitize is deprecated and will be removed in Loofah 0.3.0. Please switch to Loofah.scrub_fragment(string_or_io, :escape)"
      Loofah.scrub_fragment(string_or_io, :escape).to_xml
    end
    
    def sanitize_document(string_or_io) # :nodoc:
      warn_once "WARNING: Loofah.sanitize_document is deprecated and will be removed in Loofah 0.3.0. Please switch to Loofah.scrub_document(string_or_io, :escape)"
      Loofah.scrub_document(string_or_io, :escape).to_xml
    end

    private

    def warn_once(message) # :nodoc:
      @aooga ||= {}
      unless @aooga.key?(message)
        warn message unless @aooga[message]
        @aooga[message] = true
      end
    end
  end
end
