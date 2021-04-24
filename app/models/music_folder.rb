class MusicFolder < ActiveRecord::Base
  has_many :audio_files, dependent: :destroy
  has_many :images, dependent: :destroy

  serialize :details, Hash

  searchable :formatted_name, :folder, :subfolder, :year

  extend FriendlyId
  friendly_id :data_url

end
