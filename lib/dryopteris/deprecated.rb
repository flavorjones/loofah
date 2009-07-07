module Dryopteris

  class << self
    def strip_tags(string_or_io, encoding=nil)
      Dryopteris::HTML::Document.parse(string_or_io, nil, encoding).sanitize(:prune).inner_text
    end
    
    # def whitewash(string, encoding=nil)
    #   doc = Dryopteris::HTML::DocumentFragment.parse(string).sanitize(:whitewash)
    #   body = doc.xpath("./body").first
    #   if body
    #     body.children.to_xml
    #   else
    #     doc.to_xml
    #   end
    # end

    # def whitewash_document(string_or_io, encoding=nil)
    #   Dryopteris::HTML::Document.parse(string_or_io, nil, encoding).sanitize(:whitewash).xpath('/html/body').first.children.to_html
    # end

    def sanitize(string, encoding=nil)
      Dryopteris::HTML::DocumentFragment.parse(string).sanitize(:escape).to_xml
    end
    
    def sanitize_document(string_or_io, encoding=nil)
      Dryopteris::HTML::Document.parse(string_or_io, nil, encoding).sanitize(:escape).to_xml
    end

  end # self

end
