module Loofah
  #
  #  A drop-in replacement for XssTerminate[http://github.com/look/xss_terminate/tree/master],
  #  XssFoliate will strip all tags from your 
  #
  module XssFoliate
    #
    #  Call this method from your rails environment.rb or initializers
    #  to xss_foliate all of your models.
    #
    #  The default is to remove all HTML tags from the text and string
    #  attributes. If you'd like to skip a field or scrub it differently,
    #  use xss_foliate with approprate options.
    #
    def self.include_in_active_record_base
      ActiveRecord::Base.send(:include, Loofah::XssFoliate)
    end

    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      # sets up default of stripping tags for all fields
      base.send(:xss_foliate)
    end

    module ClassMethods
      #
      #  Annotate your model with this method to specify which fields
      #  you want scrubbed, and how you want them scrubbed.
      #
      #  Options:
      #  * :except => [array_of_fields_to_not_scrub]
      #  * :strip => [array_of_fields_to_strip_unsafe_html_tags_from]
      #  * :escape => [array_of_fields_to_escape_unsafe_html_tags_from]
      #  * :html5lib_sanitize => [array_of_fields_to_escape_unsafe_html_tags_from]
      #  * :sanitize => [array_of_fields_to_strip_ALL_html_tags_from]
      #
      #  The default is :sanitize for all fields
      #
      def xss_foliate(options = {})
        unless callback_already_registered?
          before_validation :xss_foliate_fields
          class_inheritable_reader :xss_foliate_options
          include Loofah::XssFoliate::InstanceMethods
        end

        write_inheritable_attribute(:xss_foliate_options, {
            :except => (options[:except] || []),
            :strip => (options[:strip] || []),
            :escape => (options[:escape] || []),
            :html5lib_sanitize => (options[:html5lib_sanitize] || []),
            :sanitize => (options[:sanitize] || [])
          })
      end

      private

      def callback_already_registered? # :nodoc:
        return false if before_validation_callback_chain.empty?
        before_validation_callback_chain.any? {|cb| cb.method == :xss_foliate_fields}
      end
    end
    
    module InstanceMethods

      def xss_foliate_fields # :nodoc:
        # fix a bug with Rails internal AR::Base models that get loaded before
        # the plugin, like CGI::Sessions::ActiveRecordStore::Session
        return if xss_foliate_options.nil?
        
        self.class.columns.each do |column|
          next unless (column.type == :string || column.type == :text)
          
          field = column.name.to_sym
          value = self[field]

          next if value.nil? || !value.is_a?(String)
          
          if xss_foliate_options[:except].include?(field)
            next

          elsif xss_foliate_options[:strip].include?(field)
            fragment = Loofah.scrub_fragment(value, :strip)
            self[field] = fragment.nil? ? "" : fragment.to_s

          elsif xss_foliate_options[:escape].include?(field)
            fragment = Loofah.scrub_fragment(value, :escape)
            self[field] = fragment.nil? ? "" : fragment.to_s
          elsif xss_foliate_options[:html5lib_sanitize].include?(field)
            fragment = Loofah.scrub_fragment(value, :escape)
            self[field] = fragment.nil? ? "" : fragment.to_s

          else # sanitize and use inner_html
            fragment = Loofah.scrub_fragment(value, :strip)
            self[field] = fragment.nil? ? "" : fragment.text
          end
        end
        
      end
    end
  end
end
