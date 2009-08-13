module Loofah
  #
  #  A replacement for
  #  XssTerminate[http://github.com/look/xss_terminate/tree/master],
  #  XssFoliate will strip all tags from your ActiveRecord models'
  #  string and text attributes.
  #
  #  Please read the documentation for the Loofah module for an
  #  explanation of the different scrubbing methods.
  #
  #  If you would like to pick and choose the models that are scrubbed:
  #
  #    # config/environment.rb
  #    require 'loofah/xss_foliate'
  #
  #    # db/schema.rb
  #    create_table "posts" do |t|
  #      t.string  "title"
  #      t.text    "body"
  #    end
  #    
  #    # app/model/post.rb
  #    class Post < ActiveRecord::Base
  #      xss_foliate  # scrub both title and body down to their inner text
  #    end
  #
  #    OR
  # 
  #      xss_foliate :strip => [:title, body]  # strip unsafe tags from both title and body
  #
  #    OR
  # 
  #      xss_foliate :except => :title         # scrub body but not title
  #
  #    OR
  # 
  #      # remove all tags from title, remove unsafe tags from body
  #      xss_foliate :sanitize => [:title], :scrub => [:body]
  #
  #    OR
  #
  #      # old xss_terminate code will work if you s/_terminate/_foliate/
  #      # was: xss_terminate :except => [:title], :sanitize => [:body]
  #      xss_foliate :except => [:title], :sanitize => [:body]
  #
  # Alternatively, if you'd like to scrub all fields in all your models:
  #
  #    # config/environment.rb
  #    require 'loofah/xss_foliate'
  #    ActiveRecord::Base.xss_foliate_all
  #
  module XssFoliate
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      # sets up default of stripping tags for all fields
      base.send(:xss_foliate)
    end

    module ClassMethods
      VALID_OPTIONS = [:except, :strip, :escape, :prune, :text, :html5lib_sanitize, :sanitize]
      ALIASED_OPTIONS = {:html5lib_sanitize => :escape, :sanitize => :strip}
      REAL_OPTIONS = VALID_OPTIONS - ALIASED_OPTIONS.keys

      #
      #  Annotate your model with this method to specify which fields
      #  you want scrubbed, and how you want them scrubbed. XssFoliate
      #  assumes all fields are HTLM fragments (as opposed to full
      #  documents, see Loofah for a full explanation of the
      #  difference).
      #
      #  Options:
      #  * :except => [fields] # don't scrub these fields
      #  * :strip  => [fields] # strip unsafe tags from these fields
      #  * :escape => [fields] # escape unsafe tags from these fields
      #  * :prune  => [fields] # prune unsafe tags and subtrees from these fields
      #  * :text   => [fields] # remove everything except the inner text from these fields
      #
      #  XssTerminate compatibility options:
      #  * :html5lib_sanitize => [fields] # same as :escape
      #  * :sanitize => [fields]          # same as :strip
      #  * the default behavior in XssTerminate corresponds to :text
      #
      #  The default is :text for all fields unless otherwise specified.
      #
      def xss_foliate(options = {})
        unless callback_already_registered?
          before_validation        :xss_foliate_fields
          class_inheritable_reader :xss_foliate_options
          include Loofah::XssFoliate::InstanceMethods
        end

        options.keys.each do |option|
          unless VALID_OPTIONS.include?(option)
            raise ArgumentError, "unknown xss_foliate option #{option}"
          end
        end

        REAL_OPTIONS.each { |option| options[option] = Array(options[option]) }

        ALIASED_OPTIONS.each do |option, real|
          if options[option]
            options[real] += Array(options.delete(option))
          end
        end

        write_inheritable_attribute(:xss_foliate_options, {
            :except => options[:except],
            :strip  => options[:strip],
            :escape => options[:escape],
            :prune  => options[:prune],
            :text   => options[:text]
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

          elsif xss_foliate_options[:prune].include?(field)
            fragment = Loofah.scrub_fragment(value, :prune)
            self[field] = fragment.nil? ? "" : fragment.to_s

          elsif xss_foliate_options[:escape].include?(field)
            fragment = Loofah.scrub_fragment(value, :escape)
            self[field] = fragment.nil? ? "" : fragment.to_s

          else # :text
            fragment = Loofah.scrub_fragment(value, :strip)
            self[field] = fragment.nil? ? "" : fragment.text
          end
        end
        
      end
    end
  end

  module ActiveRecordXssFoliate
    def xss_foliate
      ActiveRecord::Base.send(:include, Loofah::XssFoliate)
    end
  end
end
