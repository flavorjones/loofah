require 'cgi'

module Dryopteris

  module Sanitizer

    def sanitize(*args)
      method = args.first
      case method
      when :escape, :prune, :whitewash
        __sanitize_roots.each do |node|
          Sanitizer.__traverse_conditionally_top_down(node, "__dryopteris_#{method}".to_sym)
        end
      when :yank
        __sanitize_roots.each do |node|
          Sanitizer.__traverse_conditionally_bottom_up(node, "__dryopteris_#{method}".to_sym)
        end
      else
        raise ArgumentError, "unknown sanitize filter '#{method}'"
      end
      self
    end

    private

    class << self

      def __dryopteris_escape(node)
        case node.type
        when Nokogiri::XML::Node::ELEMENT_NODE
          if HashedWhiteList::ALLOWED_ELEMENTS[node.name]
            __scrub_attributes node
            return false
          end
        when Nokogiri::XML::Node::TEXT_NODE, Nokogiri::XML::Node::CDATA_SECTION_NODE
          return false
        end
        replacement_killer = Nokogiri::XML::Text.new(node.to_s, node.document)
        node.add_next_sibling replacement_killer
        node.remove
        return true
      end

      def __dryopteris_prune(node)
        case node.type
        when Nokogiri::XML::Node::ELEMENT_NODE
          if HashedWhiteList::ALLOWED_ELEMENTS[node.name]
            __scrub_attributes node
            return false
          end
        when Nokogiri::XML::Node::TEXT_NODE, Nokogiri::XML::Node::CDATA_SECTION_NODE
          return false
        end
        node.remove
        return true
      end

      def __dryopteris_yank(node)
        case node.type
        when Nokogiri::XML::Node::ELEMENT_NODE
          if HashedWhiteList::ALLOWED_ELEMENTS[node.name]
            __scrub_attributes node
            return false
          end
        when Nokogiri::XML::Node::TEXT_NODE, Nokogiri::XML::Node::CDATA_SECTION_NODE
          return false
        end
        replacement_killer = node.before node.inner_html
        node.remove
        return true
      end

      def __dryopteris_whitewash(node)
        case node.type
        when Nokogiri::XML::Node::ELEMENT_NODE
          if HashedWhiteList::ALLOWED_ELEMENTS[node.name]
            node.attributes.each { |attr| node.remove_attribute(attr.first) }
            return false if node.namespaces.empty?
          end
        when Nokogiri::XML::Node::TEXT_NODE, Nokogiri::XML::Node::CDATA_SECTION_NODE
          return false
        end
        node.remove
        return true
      end

      def __traverse_conditionally_top_down(node, method_name)
        return if send(method_name, node)
        node.children.each {|j| __traverse_conditionally_top_down(j, method_name)}
      end

      def __traverse_conditionally_bottom_up(node, method_name)
        node.children.each {|j| __traverse_conditionally_bottom_up(j, method_name)}
        return if send(method_name, node)
      end

      def __scrub_attributes(node)
        node.attributes.each do |attr|
          node.remove_attribute(attr.first) unless HashedWhiteList::ALLOWED_ATTRIBUTES[attr.first]
        end
        node.attributes.each do |attr|
          if HashedWhiteList::ATTR_VAL_IS_URI[attr.first]
            # this block lifted nearly verbatim from HTML5 sanitization
            val_unescaped = CGI.unescapeHTML(attr.last.to_s).gsub(/`|[\000-\040\177\s]+|\302[\200-\240]/,'').downcase
            if val_unescaped =~ /^[a-z0-9][-+.a-z0-9]*:/ and HashedWhiteList::ALLOWED_PROTOCOLS[val_unescaped.split(':')[0]].nil?
              node.remove_attribute(attr.first)
            end
          end
        end
        if node.attributes['style']
          node['style'] = __scrub_css(node.attributes['style'])
        end
      end

      #  this liftend nearly verbatim from html5
      def __scrub_css(style)
        # disallow urls
        style = style.to_s.gsub(/url\s*\(\s*[^\s)]+?\s*\)\s*/, ' ')

        # gauntlet
        return '' unless style =~ /^([:,;#%.\sa-zA-Z0-9!]|\w-\w|\'[\s\w]+\'|\"[\s\w]+\"|\([\d,\s]+\))*$/
        return '' unless style =~ /^\s*([-\w]+\s*:[^:;]*(;\s*|$))*$/

        clean = []
        style.scan(/([-\w]+)\s*:\s*([^:;]*)/) do |prop, val|
          next if val.empty?
          prop.downcase!
          if HashedWhiteList::ALLOWED_CSS_PROPERTIES[prop]
            clean << "#{prop}: #{val};"
          elsif %w[background border margin padding].include?(prop.split('-')[0])
            clean << "#{prop}: #{val};" unless val.split().any? do |keyword|
              HashedWhiteList::ALLOWED_CSS_KEYWORDS[keyword].nil? and
                keyword !~ /^(#[0-9a-f]+|rgb\(\d+%?,\d*%?,?\d*%?\)?|\d{0,2}\.?\d{0,2}(cm|em|ex|in|mm|pc|pt|px|%|,|\))?)$/
            end
          elsif HashedWhiteList::ALLOWED_SVG_PROPERTIES[prop]
            clean << "#{prop}: #{val};"
          end
        end

        style = clean.join(' ')
      end
    end

  end
end


module Dryopteris

  class << self
    def strip_tags(string_or_io, encoding=nil)
      Dryopteris::HTML::Document.parse(string_or_io, nil, encoding).sanitize(:prune).inner_text
    end
    
    def whitewash(string, encoding=nil)
      Dryopteris::HTML::DocumentFragment.parse(string).sanitize(:whitewash).to_xml
    end

    def whitewash_document(string_or_io, encoding=nil)
      Dryopteris::HTML::Document.parse(string_or_io, nil, encoding).sanitize(:whitewash).xpath('/html/body').first.children.to_html
    end

    def sanitize(string, encoding=nil)
      Dryopteris::HTML::DocumentFragment.parse(string).sanitize(:escape).to_xml
    end
    
    def sanitize_document(string_or_io, encoding=nil)
      Dryopteris::HTML::Document.parse(string_or_io, nil, encoding).sanitize(:escape).xpath('/html/body').first.children.to_xml
    end

  end # self

end
