class M3uFile < ActiveRecord::Base

  belongs_to :release

  has_paper_trail

  acts_as_paranoid

  include LocalFile

  dragonfly_accessor :file do
    storage_options {|a| { path: "m3u/%s" % [ UUID.new.generate ] } }
  end

end