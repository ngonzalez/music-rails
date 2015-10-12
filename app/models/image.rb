class Image < ActiveRecord::Base
  belongs_to :release

  dragonfly_accessor :file do
    storage_options {|a| { path: "images/%s" % [ UUID.new.generate ] } }
  end
end