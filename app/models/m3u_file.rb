class M3uFile < ActiveRecord::Base

  belongs_to :music_folder

  has_paper_trail

  acts_as_paranoid

  dragonfly_accessor :file do
    storage_options {|a| { path: "m3u_files/%s" % [ UUID.new.generate ] } }
  end
end
