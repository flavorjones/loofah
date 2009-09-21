require 'loofah'

#
#  A replacement for
#  XssTerminate[http://github.com/look/xss_terminate/tree/master],
#  XssFoliate will strip all tags from your ActiveRecord models'
#  string and text attributes.
#
#  Please read the Loofah[http://loofah.rubyforge.org/] documentation
#  for an explanation of the different scrubbing methods.
#
#  If you'd like to scrub all fields in all your models:
#
#    # config/environment.rb
#    require 'xss_foliate'
#    ActiveRecord::Base.xss_foliate
#
#  Alternatively, if you would like to pick and choose the models that are scrubbed:
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
#  OR
# 
#      xss_foliate :strip => [:title, body]  # strip unsafe tags from both title and body
#
#  OR
# 
#      xss_foliate :except => :title         # scrub body but not title
#
#  OR
# 
#      # remove all tags from title, remove unsafe tags from body
#      xss_foliate :sanitize => [:title], :scrub => [:body]
#
#  OR
#
#      # old xss_terminate code will work if you s/_terminate/_foliate/
#      # was: xss_terminate :except => [:title], :sanitize => [:body]
#      xss_foliate :except => [:title], :sanitize => [:body]
#
module XssFoliate
  VERSION = '0.1.0'

  VALID_OPTIONS = [:except, :strip, :escape, :prune, :text, :html5lib_sanitize, :sanitize] # :nodoc:
  ALIASED_OPTIONS = {:html5lib_sanitize => :escape, :sanitize => :strip} # :nodoc:
  REAL_OPTIONS = VALID_OPTIONS - ALIASED_OPTIONS.keys # :nodoc:

  module ClassMethods
    #
    #  Annotate your model with this method to specify which fields
    #  you want scrubbed, and how you want them scrubbed. XssFoliate
    #  assumes all character fields are HTML fragments (as opposed to
    #  full documents, see the Loofah[http://loofah.rubyforge.org/]
    #  documentation for a full explanation of the difference).
    #
    #  Options:
    #
    #   * :except => [fields] # don't scrub these fields
    #   * :strip  => [fields] # strip unsafe tags from these fields
    #   * :escape => [fields] # escape unsafe tags from these fields
    #   * :prune  => [fields] # prune unsafe tags and subtrees from these fields
    #   * :text   => [fields] # remove everything except the inner text from these fields
    #
    #  XssTerminate compatibility options (note that the default
    #  behavior in XssTerminate corresponds to :text)
    #
    #   * :html5lib_sanitize => [fields] # same as :escape
    #   * :sanitize          => [fields] # same as :strip
    #
    #  The default is :text for all fields unless otherwise specified.
    #
    def xss_foliate(options = {})
      callback_already_declared = \
         if respond_to?(:before_validation_callback_chain)
           # Rails 2.1 and later
           before_validation_callback_chain.any? {|cb| cb.method == :xss_foliate_fields}
         else
           # Rails 2.0
           cbs = read_inheritable_attribute(:before_validation)
           (! cbs.nil?) && cbs.any? {|cb| cb == :xss_foliate_fields}
         end

      unless callback_already_declared
        before_validation        :xss_foliate_fields
        class_inheritable_reader :xss_foliate_options
        include XssFoliate::InstanceMethods
      end

      options.keys.each do |option|
        unless VALID_OPTIONS.include?(option)
          raise ArgumentError, "unknown xss_foliate option #{option}"
        end
      end

      REAL_OPTIONS.each { |option| options[option] = Array(options[option]) }

      ALIASED_OPTIONS.each do |option, real|
        options[real] += Array(options.delete(option)) if options[option]
      end

      write_inheritable_attribute(:xss_foliate_options, {
          :except => options[:except],
          :strip  => options[:strip],
          :escape => options[:escape],
          :prune  => options[:prune],
          :text   => options[:text]
        })
    end

    #
    #  class method to determine whether or not this model is applying
    #  xss_foliation to its attributes.
    #
    def xss_foliated?
      options = read_inheritable_attribute(:xss_foliate_options)
      ! (options.nil? || options.empty?)
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

ActiveRecord::Base.extend(XssFoliate::ClassMethods)

if defined?(LOOFAH_XSS_FOLIATE_ALL_MODELS) && LOOFAH_XSS_FOLIATE_ALL_MODELS
  ActiveRecord::Base.xss_foliate
end
