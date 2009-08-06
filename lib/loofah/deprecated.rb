module Loofah
  class << self
    def strip_tags(string_or_io)
      Loofah.document(string_or_io).scrub!(:prune).text
    end
    
    def whitewash(string_or_io)
      Loofah.fragment(string_or_io).scrub!(:whitewash).to_s
    end

    def whitewash_document(string_or_io)
      Loofah.document(string_or_io).scrub!(:whitewash).to_s
    end

    def sanitize(string_or_io)
      Loofah.fragment(string_or_io).scrub!(:escape).to_xml
    end
    
    def sanitize_document(string_or_io)
      Loofah.document(string_or_io).scrub!(:escape).to_xml
    end
  end
end
