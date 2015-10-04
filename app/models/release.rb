class Release < ActiveRecord::Base
  has_many :tracks, dependent: :destroy
  has_many :images, dependent: :destroy

  serialize :details, Hash

  searchable do
    text :formatted_name
  end
end