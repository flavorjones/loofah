module Dryopteris

  class << self
    def strip_tags(string_or_io, encoding=nil)
      Dryopteris::HTML::Document.parse(string_or_io, nil, encoding).sanitize!(:prune).text
    end
    
    def whitewash(string, encoding=nil)
      Dryopteris::HTML::DocumentFragment.parse(string).sanitize!(:whitewash).to_s
    end

    def whitewash_document(string_or_io, encoding=nil)
      Dryopteris::HTML::Document.parse(string_or_io, nil, encoding).sanitize!(:whitewash).to_s
    end

    def sanitize(string, encoding=nil)
      Dryopteris::HTML::DocumentFragment.parse(string).sanitize!(:escape).to_xml
    end
    
    def sanitize_document(string_or_io, encoding=nil)
      Dryopteris::HTML::Document.parse(string_or_io, nil, encoding).sanitize!(:escape).to_xml
    end
  end # self

end
