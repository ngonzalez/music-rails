class AudioFile < ActiveRecord::Base
  belongs_to :music_folder

  dragonfly_accessor :file do
    storage_options {|a| { path: "audio_files/%s" % [ UUID.new.generate ] } }
  end

  has_paper_trail

  acts_as_paranoid

  searchable do
    text :artist
    text :album
    text :title, :default_boost => 2
    text :genre
    integer :year do
      year.to_i
    end
  end

  extend FriendlyId
  friendly_id :data_url

end
