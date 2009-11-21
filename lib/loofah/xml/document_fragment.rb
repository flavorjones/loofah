module Loofah
  module XML
    #
    #  Subclass of Nokogiri::XML::DocumentFragment. Also includes Loofah::ScrubberInstanceMethods.
    #
    #  See Loofah::InstanceMethods for additional methods.
    #
    class DocumentFragment < Nokogiri::XML::DocumentFragment
      include Loofah::InstanceMethods

      class << self
        #
        #  Overridden Nokogiri::XML::DocumentFragment
        #  constructor. Applications should use Loofah.fragment to
        #  parse a fragment.
        #
        def parse tags
          self.new(Loofah::XML::Document.new, tags)
        end
      end

      #
      #  Returns the XML markup contained by the fragment or document
      #
      def to_s
        sanitize_roots.children.to_s
      end
      alias :serialize :to_s

      private

      def sanitize_roots # :nodoc:
        xpath("./body").first || self
      end

    end
  end
end
