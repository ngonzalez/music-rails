class Release < ActiveRecord::Base
  has_many :tracks, dependent: :destroy
  searchable do
    text :name
  end
end