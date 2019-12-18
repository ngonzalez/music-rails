class Release < ActiveRecord::Base
  has_many :tracks, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :nfo_files, dependent: :destroy
  has_many :sfv_files, dependent: :destroy
  has_many :m3u_files, dependent: :destroy

  serialize :details, Hash

  has_paper_trail

  acts_as_paranoid

  searchable do
    text :formatted_name
    string :folder
    string :subfolder
    integer :year
  end

  extend FriendlyId
  friendly_id :data_url

end