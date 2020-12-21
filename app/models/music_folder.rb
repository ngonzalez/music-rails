class MusicFolder < ActiveRecord::Base
  has_many :audio_files, dependent: :destroy
  has_many :images, dependent: :destroy

  serialize :details, Hash

  searchable do
    text :formatted_name
    string :folder
    string :subfolder
    integer :year
  end

  extend FriendlyId
  friendly_id :data_url

end
