# frozen_string_literal: true
module Loofah
  module HTML5 # :nodoc:
    #
    #  Subclass of Nokogiri::HTML5::Document.
    #
    #  See Loofah::ScrubBehavior and Loofah::TextBehavior for additional methods.
    #
    class Document < Nokogiri::HTML5::Document
      include Loofah::ScrubBehavior::Node
      include Loofah::DocumentDecorator
      include Loofah::TextBehavior

      class << self
        def parse(*args, &block)
          remove_comments_before_html_element(super)
        end

        private

        # remove comments that exist outside of the HTML element.
        #
        # these comments are allowed by the HTML spec:
        #
        #    https://www.w3.org/TR/html401/struct/global.html#h-7.1
        #
        # but are not scrubbed by Loofah because these nodes don't meet
        # the contract that scrubbers expect of a node (e.g., it can be
        # replaced, sibling and children nodes can be created).
        def remove_comments_before_html_element(doc)
          doc.children.each do |child|
            child.unlink if child.comment?
          end
          doc
        end
      end

      def serialize_root
        at_xpath("/html/body")
      end
    end
  end
end
