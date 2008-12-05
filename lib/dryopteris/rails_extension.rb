require "dryopteris"

module Dryopteris
  module RailsExtension
    def self.included(base)
      base.extend(ClassMethods)
      
      # sets up default of stripping tags for all fields
      base.class_eval do
        before_save :sanitize_fields
        class_inheritable_reader :dryopteris_options
      end
    end

    module ClassMethods
      def sanitize_fields(options = {})
        write_inheritable_attribute(:dryopteris_options, {
          :except     => (options[:except] || []),
          :allow_tags => (options[:allow_tags] || [])
        })
      end
      
      alias_method :sanitize_field, :sanitize_fields
    end

      
    def sanitize_fields
      self.class.columns.each do |column|
        next unless (column.type == :string || column.type == :text)

        field = column.name.to_sym
        value = self[field]

        if dryopteris_options && dryopteris_options[:except].include?(field)
          next
        elsif dryopteris_options && dryopteris_options[:allow_tags].include?(field)
          self[field] = Dryopteris.sanitize(value)
        else
          self[field] = Dryopteris.strip_tags(value)
        end
      end
      
    end
    
  end
end