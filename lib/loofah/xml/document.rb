module Loofah
  module XML # :nodoc:
    #
    #  Subclass of Nokogiri::XML::Document.
    #
    #  See Loofah::InstanceMethods for additional methods.
    #
    class Document < Nokogiri::XML::Document
      include Loofah::InstanceMethods
    end
  end
end
