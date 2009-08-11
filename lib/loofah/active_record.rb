module Loofah
  #
  # Loofah can scrub ActiveRecord attributes in a before_save callback:
  #
  #   # in environment.rb
  #   require 'loofah/active_record'
  #
  #   # db/schema.rb
  #   create_table "posts" do |t|
  #     t.string  "title"
  #     t.string  "body"
  #   end
  #
  #   # app/model/post.rb
  #   class Post < ActiveRecord::Base
  #     html_fragment :body, :scrub => :prune  # scrubs 'body' in a before_save
  #   end
  #
  module ActiveRecord
    #
    #  scrub an ActiveRecord attribute +attr+ as an HTML fragment
    #  using the method specified in the required +:scrub+ option.
    #
    def html_fragment(attr, options={})
      raise ArgumentError, "html_fragment requires :scrub option" unless method = options[:scrub]
      before_save do |record|
        record[attr] = Loofah.scrub_fragment(record[attr], method)
      end
    end

    #
    #  scrub an ActiveRecord attribute +attr+ as an HTML document
    #  using the method specified in the required +:scrub+ option.
    #
    def html_document(attr, options={})
      raise ArgumentError, "html_document requires :scrub option" unless method = options[:scrub]
      before_save do |record|
        record[attr] = Loofah.scrub_document(record[attr], method)
      end
    end
  end
end

ActiveRecord::Base.extend(Loofah::ActiveRecord)
