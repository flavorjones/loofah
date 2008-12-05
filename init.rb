require "dryopteris/rails_extension"
ActiveRecord::Base.send(:include, Dryopteris::RailsExtension)
