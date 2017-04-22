class NfoFile < ImageBase
  include LocalFile

  dragonfly_accessor :file do
    storage_options {|a| { path: "images/%s" % [ UUID.new.generate ] } }
  end
end