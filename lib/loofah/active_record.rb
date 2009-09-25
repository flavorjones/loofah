module Loofah
  #
  # Loofah can scrub ActiveRecord attributes in a before_validation callback:
  #
  #   # in environment.rb
  #   Rails::Initializer.run do |config|
  #     config.gem 'loofah'
  #   end
  #
  #   # db/schema.rb
  #   create_table "posts" do |t|
  #     t.string  "title"
  #     t.string  "body"
  #   end
  #
  #   # app/model/post.rb
  #   class Post < ActiveRecord::Base
  #     html_fragment :body, :scrub => :prune  # scrubs 'body' in a before_validation
  #   end
  #
  module ActiveRecordExtension
    #
    #  :call-seq:
    #    model.html_fragment(attribute, :scrub => sanitization_method)
    #
    #  Scrub an ActiveRecord attribute +attribute+ as an HTML *fragment*
    #  using the method specified by +sanitization_method+.
    #
    #  +sanitization_method+ must be one of:
    #
    #  * :string
    #  * :prune
    #  * :escape
    #  * :whitewash
    #
    #  See Loofah for an explanation of each sanitization method.
    #
    def html_fragment(attr, options={})
      raise ArgumentError, "html_fragment requires :scrub option" unless method = options[:scrub]
      before_validation do |record|
        record[attr] = Loofah.scrub_fragment(record[attr], method).to_s
      end
    end

    #
    #  :call-seq:
    #    model.html_document(attribute, :scrub => sanitization_method)
    #
    #  Scrub an ActiveRecord attribute +attribute+ as an HTML *document*
    #  using the method specified by +sanitization_method+.
    #
    #  +sanitization_method+ must be one of:
    #
    #  * :string
    #  * :prune
    #  * :escape
    #  * :whitewash
    #
    #  See Loofah for an explanation of each sanitization method.
    #
    def html_document(attr, options={})
      raise ArgumentError, "html_document requires :scrub option" unless method = options[:scrub]
      before_validation do |record|
        record[attr] = Loofah.scrub_document(record[attr], method).to_s
      end
    end
  end
end

ActiveRecord::Base.extend(Loofah::ActiveRecordExtension)
