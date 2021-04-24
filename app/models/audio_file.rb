class AudioFile < ActiveRecord::Base
  belongs_to :music_folder

  dragonfly_accessor :file do
    storage_options {|a| { path: "audio_files/%s" % [ UUID.new.generate ] } }
  end
  
  searchable :artist, :album, :title, :genre, :year

  extend FriendlyId
  friendly_id :data_url

end
