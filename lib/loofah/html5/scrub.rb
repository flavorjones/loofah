#encoding: US-ASCII

require 'cgi'

module Loofah
  module HTML5 # :nodoc:
    module Scrub

      CONTROL_CHARACTERS = if RUBY_VERSION =~ /^1\.8/
                             /`|[\000-\040\177\s]+|\302[\200-\240]/
                           else
                             /[`\u0000-\u0020\u007F\s\u0080-\u0101]/
                           end

      class << self

        def allowed_element? element_name
          ::Loofah::HTML5::WhiteList::ALLOWED_ELEMENTS_WITH_LIBXML2.include? element_name
        end

        #  alternative implementation of the html5lib attribute scrubbing algorithm
        def scrub_attributes node
          node.attribute_nodes.each do |attr_node|
            attr_name = if attr_node.namespace
                          "#{attr_node.namespace.prefix}:#{attr_node.node_name}"
                        else
                          attr_node.node_name
                        end
            unless WhiteList::ALLOWED_ATTRIBUTES.include?(attr_name)
              attr_node.remove
              next
            end
            if WhiteList::ATTR_VAL_IS_URI.include?(attr_name)
              # this block lifted nearly verbatim from HTML5 sanitization
              val_unescaped = CGI.unescapeHTML(attr_node.value).gsub(CONTROL_CHARACTERS,'').downcase
              if val_unescaped =~ /^[a-z0-9][-+.a-z0-9]*:/ && ! WhiteList::ALLOWED_PROTOCOLS.include?(val_unescaped.split(':')[0])
                attr_node.remove
                next
              end
            end
            if WhiteList::SVG_ATTR_VAL_ALLOWS_REF.include?(attr_name)
              attr_node.value = attr_node.value.gsub(/url\s*\(\s*[^#\s][^)]+?\)/m, ' ') if attr_node.value
            end
            if WhiteList::SVG_ALLOW_LOCAL_HREF.include?(node.name) && attr_name == 'xlink:href' && attr_node.value =~ /^\s*[^#\s].*/m
              attr_node.remove
              next
            end
          end
          if node.attributes['style']
            node['style'] = scrub_css node.attributes['style']
          end
        end

        #  lifted nearly verbatim from html5lib
        def scrub_css style
          # disallow urls
          style = style.to_s.gsub(/url\s*\(\s*[^\s)]+?\s*\)\s*/, ' ')

          # gauntlet
          return '' unless style =~ /^([:,;#%.\sa-zA-Z0-9!]|\w-\w|\'[\s\w]+\'|\"[\s\w]+\"|\([\d,\s]+\))*$/
          return '' unless style =~ /^\s*([-\w]+\s*:[^:;]*(;\s*|$))*$/

          clean = []
          style.scan(/([-\w]+)\s*:\s*([^:;]*)/) do |prop, val|
            next if val.empty?
            prop.downcase!
            if WhiteList::ALLOWED_CSS_PROPERTIES.include?(prop)
              clean << "#{prop}: #{val};"
            elsif %w[background border margin padding].include?(prop.split('-')[0])
              clean << "#{prop}: #{val};" unless val.split().any? do |keyword|
                WhiteList::ALLOWED_CSS_KEYWORDS.include?(keyword) &&
                  keyword !~ /^(#[0-9a-f]+|rgb\(\d+%?,\d*%?,?\d*%?\)?|\d{0,2}\.?\d{0,2}(cm|em|ex|in|mm|pc|pt|px|%|,|\))?)$/
              end
            elsif WhiteList::ALLOWED_SVG_PROPERTIES.include?(prop)
              clean << "#{prop}: #{val};"
            end
          end

          style = clean.join(' ')
        end

      end

    end
  end
end
