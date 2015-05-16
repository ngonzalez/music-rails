class Track < ActiveRecord::Base
  belongs_to :release

  searchable do
    text :artist
    text :album
    text :title, :default_boost => 2
    text :release do
      release.name
    end
  end

end