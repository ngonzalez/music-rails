class Release < ActiveRecord::Base
  has_many :tracks, dependent: :destroy
  searchable do
    text :name
  end

  def path
    [BASE_URL, self.folder, self.name].join("/")
  end
end