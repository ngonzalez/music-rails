class Release < ActiveRecord::Base
  has_many :tracks, dependent: :destroy
  has_many :images, dependent: :destroy

  serialize :details, Hash

  has_paper_trail

  acts_as_paranoid

  searchable do
    text :formatted_name
    text :label_name
  end
end