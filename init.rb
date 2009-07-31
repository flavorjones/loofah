require "loofah/rails_extension"
ActiveRecord::Base.send(:include, Loofah::RailsExtension)
