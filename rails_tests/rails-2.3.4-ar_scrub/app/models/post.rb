class Post < ActiveRecord::Base
  html_fragment :body, :scrub => :strip
end
