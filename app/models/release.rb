class Release < ActiveRecord::Base
  has_many :tracks, dependent: :destroy
  has_many :images, dependent: :destroy

  searchable do
    text :name
  end

  def path
    [BASE_URL, self.folder, self.name].join("/")
  end
end