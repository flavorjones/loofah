module Loofah
  module XML # :nodoc:
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

      private

      def sanitize_roots # :nodoc:
        self
      end

    end
  end
end
