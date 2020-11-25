class Image < ImageBase
  belongs_to :music_folder

  has_paper_trail

  acts_as_paranoid

  dragonfly_accessor :file do
    storage_options {|a| { path: "images/%s" % [ UUID.new.generate ] } }
    copy_to(:thumb){|a| a.thumb("300x250>") }
    copy_to(:thumb_high){|a| a.thumb("600x500>") }
  end

  dragonfly_accessor :thumb do
    storage_options {|a| { path: "thumbs/%s" % [ UUID.new.generate ] } }
  end

  dragonfly_accessor :thumb_high do
    storage_options {|a| { path: "thumbs/%s" % [ UUID.new.generate ] } }
  end
end