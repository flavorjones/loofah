require 'rubygems'
gem 'nokogiri', '>=1.0.5'
require 'nokogiri'
require 'cgi'

require "dryopteris/whitelist"

module Dryopteris

  class << self
    def strip_tags(string_or_io, encoding=nil)
      return nil if string_or_io.nil?
      return "" if string_or_io.strip.size == 0
      
      doc = Nokogiri::HTML.parse(string_or_io, nil, encoding)
      body_element = doc.at("/html/body")
      return "" if body_element.nil?
      body_element.inner_text
    end
    

    def whitewash(string, encoding=nil)
      return nil if string.nil?
      return "" if string.strip.size == 0

      string = "<html><body>" + string + "</body></html>"
      doc = Nokogiri::HTML.parse(string, nil, encoding)
      body = doc.xpath("/html/body").first
      return "" if body.nil?
      body.children.each do |node|
        traverse_conditionally_top_down(node, :whitewash_node)
      end
      body.children.map { |x| x.to_xml }.join
    end

    def whitewash_document(string_or_io, encoding=nil)
      return nil if string_or_io.nil?
      return "" if string_or_io.strip.size == 0

      doc = Nokogiri::HTML.parse(string_or_io, nil, encoding)
      body = doc.xpath("/html/body").first
      return "" if body.nil?
      body.children.each do |node|
        traverse_conditionally_top_down(node, :whitewash_node)
      end
      body.children.map { |x| x.to_xml }.join
    end


    def sanitize(string, encoding=nil)
      return nil if string.nil?
      return "" if string.strip.size == 0
      
      string = "<html><body>" + string + "</body></html>"
      doc = Nokogiri::HTML.parse(string, nil, encoding)
      body = doc.xpath("/html/body").first
      return "" if body.nil?
      body.children.each do |node| 
        traverse_conditionally_top_down(node, :sanitize_node)
      end
      body.children.map { |x| x.to_xml }.join
    end
    
    def sanitize_document(string_or_io, encoding=nil)
      return nil if string_or_io.nil?
      return "" if string_or_io.strip.size == 0
      
      doc = Nokogiri::HTML.parse(string_or_io, nil, encoding)
      elements = doc.xpath("/html/head/*","/html/body/*")
      return "" if (elements.nil? || elements.empty?)
      elements.each do |node| 
        traverse_conditionally_top_down(node, :sanitize_node)
      end
      doc.root.to_xml
    end

    private

    def traverse_conditionally_top_down(node, method_name)
      return if send(method_name, node)
      node.children.each {|j| traverse_conditionally_top_down(j, method_name)}
    end

    def remove_tags_from_node(node)
      replacement_killer = Nokogiri::XML::Text.new(node.text, node.document)
      node.add_next_sibling(replacement_killer)
      node.remove
      return true
    end

    def sanitize_node(node)
      case node.type
      when 1 # Nokogiri::XML::Node::ELEMENT_NODE
        if HashedWhiteList::ALLOWED_ELEMENTS[node.name]
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
            node['style'] = sanitize_css(node.attributes['style'])
          end
          return false
        end
      when 3 # Nokogiri::XML::Node::TEXT_NODE
        return false
      when 4 # Nokogiri::XML::Node::CDATA_SECTION_NODE
        return false
      end
      replacement_killer = Nokogiri::XML::Text.new(node.to_s, node.document)
      node.add_next_sibling(replacement_killer)
      node.remove
      return true
    end


    def whitewash_node(node)
      case node.type
      when 1 # Nokogiri::XML::Node::ELEMENT_NODE
        if HashedWhiteList::ALLOWED_ELEMENTS[node.name]
          node.attributes.each { |attr| node.remove_attribute(attr.first) }
          has_no_namespaces = true
          begin
            has_no_namespaces = node.namespaces.empty?
          rescue
            # older versions of nokogiri raise an exception when there
            # is a namespace on the node that is not declared with an href.
            # see http://github.com/tenderlove/nokogiri/commit/395d7971304e1489e92c494b9c50609f4b4c4ab0
            has_no_namespaces = false
          end
          return false if has_no_namespaces
        end
      when 3 # Nokogiri::XML::Node::TEXT_NODE
        return false
      when 4 # Nokogiri::XML::Node::CDATA_SECTION_NODE
        return false
      end
      node.remove
      return true
    end


    #  this liftend nearly verbatim from html5
    def sanitize_css(style)
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

  end # self

  module HashedWhiteList
    #  turn each of the whitelist arrays into a hash for faster lookup
    WhiteList.constants.each do |constant|
      next unless WhiteList.module_eval("#{constant}").is_a?(Array)
      module_eval <<-CODE
        #{constant} = {}
        WhiteList::#{constant}.each { |c| #{constant}[c] = true ; #{constant}[c.downcase] = true }
      CODE
    end
  end

end
