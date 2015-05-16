class AddTsvIndexes < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute("CREATE INDEX 'tsv_release_name' ON 'releases' USING gin(to_tsvector('search_cfg_en', 'tsv_name'));")
    ActiveRecord::Base.connection.execute("CREATE INDEX 'tsv_tracks_album' ON 'tracks' USING gin(to_tsvector('search_cfg_en', 'tsv_album'));")
    ActiveRecord::Base.connection.execute("CREATE INDEX 'tsv_tracks_artist' ON 'tracks' USING gin(to_tsvector('search_cfg_en', 'tsv_artist'));")
    ActiveRecord::Base.connection.execute("CREATE INDEX 'tsv_tracks_title' ON 'tracks' USING gin(to_tsvector('search_cfg_en', 'tsv_title'));")
  end
end