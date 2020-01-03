class Track < ActiveRecord::Base
  belongs_to :release

  dragonfly_accessor :file do
    storage_options {|a| { path: "tracks/%s" % [ UUID.new.generate ] } }
  end

  has_paper_trail

  acts_as_paranoid

  searchable do
    text :artist
    text :album
    text :title, :default_boost => 2
    text :genre
    integer :year do
      year.to_i
    end
  end
end