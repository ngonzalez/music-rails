class Release < ActiveRecord::Base
  has_many :tracks, dependent: :destroy
  has_many :images, dependent: :destroy

  serialize :details, Hash

  has_paper_trail

  acts_as_paranoid

  searchable do
    text :formatted_name
    string :label_name
    integer :year
  end

  dragonfly_accessor :sfv do
    storage_options {|a| { path: "sfv/%s" % [ UUID.new.generate ] } }
  end

  dragonfly_accessor :srrdb_sfv do
    storage_options {|a| { path: "srrdb_sfv/%s" % [ UUID.new.generate ] } }
  end

end