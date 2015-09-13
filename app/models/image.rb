class Image < ActiveRecord::Base
  belongs_to :release
  dragonfly_accessor :file
end