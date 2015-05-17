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

  def file_url
    [ BASE_URL, release.folder, release.name, URI::escape(name) ].join("/")
  end

end