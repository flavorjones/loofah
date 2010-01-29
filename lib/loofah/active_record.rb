module Loofah
  #
  # Loofah can scrub ActiveRecord attributes in a before_validation callback:
  #
  #   # config/initializers/loofah.rb
  #   require 'loofah'
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
    #    html_fragment(attribute, :scrub => scrubber_specification)
    #
    #  Scrub an ActiveRecord attribute +attribute+ as an HTML *fragment*
    #  using the method specified by +scrubber_specification+.
    #
    #  +scrubber_specification+ must be an argument acceptable to Loofah::ScrubBehavior.scrub!, namely:
    #
    #  * a symbol for one of the built-in scrubbers (see Loofah::Scrubbers for a full list)
    #  * or a Scrubber instance. (see Loofah::Scrubber for help on implementing a custom scrubber)
    #
    def html_fragment(attr, options={})
      raise ArgumentError, "html_fragment requires :scrub option" unless method = options[:scrub]
      before_validation do |record|
        record[attr] = Loofah.scrub_fragment(record[attr], method).to_s
      end
    end

    #
    #  :call-seq:
    #    model.html_document(attribute, :scrub => scrubber_specification)
    #
    #  Scrub an ActiveRecord attribute +attribute+ as an HTML *document*
    #  using the method specified by +scrubber_specification+.
    #
    #  +scrubber_specification+ must be an argument acceptable to Loofah::ScrubBehavior.scrub!, namely:
    #
    #  * a symbol for one of the built-in scrubbers (see Loofah::Scrubbers for a full list)
    #  * or a Scrubber instance.
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
