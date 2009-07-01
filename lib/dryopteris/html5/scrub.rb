require 'cgi'

module Dryopteris
  module HTML5
    module Scrub

      class << self

        def scrub_attributes(node)
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
            node['style'] = scrub_css(node.attributes['style'])
          end
        end

        #  this liftend nearly verbatim from html5
        def scrub_css(style)
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
end

