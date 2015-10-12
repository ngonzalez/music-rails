class Upload < ActiveRecord::Base
  dragonfly_accessor :file

  has_paper_trail

  acts_as_paranoid
end