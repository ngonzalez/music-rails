class Image < ActiveRecord::Base
  belongs_to :release

  has_paper_trail

  acts_as_paranoid

  dragonfly_accessor :file do
    storage_options {|a| { path: "images/%s" % [ UUID.new.generate ] } }
    copy_to(:thumb){|a| a.thumb("300x250>") if [NFO_TYPE].exclude?(a.file_type) }
    copy_to(:thumb_high){|a| a.thumb("600x500>") if [NFO_TYPE].exclude?(a.file_type) }
  end

  dragonfly_accessor :thumb do
    storage_options {|a| { path: "thumbs/%s" % [ UUID.new.generate ] } }
  end

  dragonfly_accessor :thumb_high do
    storage_options {|a| { path: "thumbs/%s" % [ UUID.new.generate ] } }
  end

end