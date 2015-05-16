class Track < ActiveRecord::Base
  belongs_to :release

  searchable do
    text :artist
    text :album
    text :title, :default_boost => 2
    text :release do
      release.name
    end
    string :sort_title do
      title.downcase.gsub(/^(an?|the)/, '') rescue title
    end
  end

end