class Release < ActiveRecord::Base
  has_many :tracks
  searchable do
    text :name
  end
end