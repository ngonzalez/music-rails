class NfoFile < ImageBase
  dragonfly_accessor :file do
    storage_options {|a| { path: "nfo/%s" % [ UUID.new.generate ] } }
  end
end