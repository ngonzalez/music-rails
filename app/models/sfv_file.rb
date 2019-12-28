class SfvFile < ActiveRecord::Base

  belongs_to :release

  has_paper_trail

  acts_as_paranoid

  dragonfly_accessor :file do
    storage_options {|a| { path: "sfv/%s" % [ UUID.new.generate ] } }
  end
end
