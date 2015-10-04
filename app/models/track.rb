class Track < ActiveRecord::Base
  belongs_to :release

  dragonfly_accessor :file

  dragonfly_accessor :encoded_file

  searchable do
    text :artist
    text :album
    text :title, :default_boost => 2
    text :genre
    text :release do
      release.name
    end
    integer :year do
      year.to_i
    end
  end
end