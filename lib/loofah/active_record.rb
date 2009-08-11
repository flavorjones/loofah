module Loofah
  module ActiveRecord
    module ClassMethods
      def html_fragment(attr, options={})
        raise ArgumentError, "html_fragment requires :scrub option" unless method = options[:scrub]
        before_save do |record|
          record[attr] = Loofah.scrub_fragment(record[attr], method)
        end
      end

      def html_document(attr, options={})
        raise ArgumentError, "html_document requires :scrub option" unless method = options[:scrub]
        before_save do |record|
          record[attr] = Loofah.scrub_document(record[attr], method)
        end
      end
    end
  end
end

ActiveRecord::Base.extend(Loofah::ActiveRecord::ClassMethods)
