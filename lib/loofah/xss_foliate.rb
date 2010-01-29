module Loofah
  #
  #  A replacement for
  #  XssTerminate[http://github.com/look/xss_terminate/tree/master],
  #  XssFoliate will strip all tags from your ActiveRecord models'
  #  string and text attributes.
  #
  #  Please read the Loofah documentation for an explanation of the
  #  different scrubbing methods, and
  #  Loofah::XssFoliate::ClassMethods for more information on the
  #  methods.
  #
  #  If you'd like to scrub all fields in all your models (and perhaps *opt-out* in specific models):
  #
  #    # config/initializers/loofah.rb
  #    require 'loofah'
  #    Loofah::XssFoliate.xss_foliate_all_models
  #
  #    # db/schema.rb
  #    create_table "posts" do |t|
  #      t.string  "title"
  #      t.text    "body"
  #      t.string  "author"
  #    end
  #
  #    # app/model/post.rb
  #    class Post < ActiveRecord::Base
  #      #  by default, title, body and author will all be scrubbed down to their inner text
  #    end
  #
  #  OR
  #
  #    # app/model/post.rb
  #    class Post < ActiveRecord::Base
  #      xss_foliate :except => :author  # opt-out of sanitizing author
  #    end
  #
  #  OR
  #
  #      xss_foliate :strip => [:title, body]  # strip unsafe tags from both title and body
  #
  #  OR
  #
  #      xss_foliate :except => :title         # scrub body and author but not title
  #
  #  OR
  #
  #      # remove all tags from title, remove unsafe tags from body
  #      xss_foliate :sanitize => :title, :scrub => :body
  #
  #  OR
  #
  #      # old xss_terminate code will work if you s/_terminate/_foliate/
  #      # was: xss_terminate :except => [:title], :sanitize => [:body]
  #      xss_foliate :except => [:title], :sanitize => [:body]
  #
  #  Alternatively, if you would like to *opt-in* to the models and attributes that are sanitized:
  #
  #    # config/initializers/loofah.rb
  #    require 'loofah'
  #    ## note omission of call to Loofah::XssFoliate.xss_foliate_all_models
  #
  #    # db/schema.rb
  #    create_table "posts" do |t|
  #      t.string  "title"
  #      t.text    "body"
  #      t.string  "author"
  #    end
  #
  #    # app/model/post.rb
  #    class Post < ActiveRecord::Base
  #      xss_foliate  # scrub title, body and author down to their inner text
  #    end
  #
  module XssFoliate
    #
    #  A replacement for
    #  XssTerminate[http://github.com/look/xss_terminate/tree/master],
    #  XssFoliate will strip all tags from your ActiveRecord models'
    #  string and text attributes.
    #
    #  See Loofah::XssFoliate for more example usage.
    #
    module ClassMethods
      # :stopdoc:
      VALID_OPTIONS = [:except, :html5lib_sanitize, :sanitize] + Loofah::Scrubbers.scrubber_symbols
      ALIASED_OPTIONS = {:html5lib_sanitize => :escape, :sanitize => :strip}
      REAL_OPTIONS = VALID_OPTIONS - ALIASED_OPTIONS.keys
      # :startdoc:

      #
      #  Annotate your model with this method to specify which fields
      #  you want scrubbed, and how you want them scrubbed. XssFoliate
      #  assumes all character fields are HTML fragments (as opposed to
      #  full documents, see the Loofah[http://loofah.rubyforge.org/]
      #  documentation for a full explanation of the difference).
      #
      #  Example call:
      #
      #   xss_foliate :except => :author, :strip => :body, :prune => [:title, :description]
      #
      #  *Note* that the values in the options hash can be either an
      #  array of attributes or a single attribute.
      #
      #  Options:
      #
      #   :except => [fields] # don't scrub these fields
      #   :strip  => [fields] # strip unsafe tags from these fields
      #   :escape => [fields] # escape unsafe tags from these fields
      #   :prune  => [fields] # prune unsafe tags and subtrees from these fields
      #   :text   => [fields] # remove everything except the inner text from these fields
      #
      #  XssTerminate compatibility options (note that the default
      #  behavior in XssTerminate corresponds to :text)
      #
      #   :html5lib_sanitize => [fields] # same as :escape
      #   :sanitize          => [fields] # same as :strip
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
          raise ArgumentError, "unknown xss_foliate option #{option}" unless VALID_OPTIONS.include?(option)
        end

        REAL_OPTIONS.each do |option|
          options[option] = Array(options[option]).collect { |val| val.to_sym }
        end

        ALIASED_OPTIONS.each do |option, real|
          options[real] += Array(options.delete(option)).collect { |val| val.to_sym } if options[option]
        end

        write_inheritable_attribute(:xss_foliate_options, options)
      end

      #
      #  Class method to determine whether or not this model is applying
      #  xss_foliation to its attributes. Could be useful in test suites.
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

          next if xss_foliate_options[:except].include?(field)

          next if xss_foliated_with_standard_scrubber(field)

          # :text if we're here
          fragment = Loofah.scrub_fragment(value, :strip)
          self[field] = fragment.nil? ? "" : fragment.text
        end
      end

      private

      def xss_foliated_with_standard_scrubber(field)
        Loofah::Scrubbers.scrubber_symbols.each do |method|
          if xss_foliate_options[method].include?(field)
            fragment = Loofah.scrub_fragment(self[field], method)
            self[field] = fragment.nil? ? "" : fragment.to_s
            return true
          end
        end
        false
      end
    end

    def self.xss_foliate_all_models
      ActiveRecord::Base.xss_foliate
    end
  end
end

ActiveRecord::Base.extend(Loofah::XssFoliate::ClassMethods)

if defined?(LOOFAH_XSS_FOLIATE_ALL_MODELS) && LOOFAH_XSS_FOLIATE_ALL_MODELS
  Loofah::XssFoliate.xss_foliate_all_models
end
