class CreatePgSearchConfigurations < ActiveRecord::Migration
  def change

    ActiveRecord::Base.connection.execute("CREATE EXTENSION IF NOT EXISTS unaccent;")
    ActiveRecord::Base.connection.execute("DROP TEXT SEARCH CONFIGURATION IF EXISTS search_cfg_en")
    ActiveRecord::Base.connection.execute("CREATE TEXT SEARCH CONFIGURATION search_cfg_en (parser=default);")
    ActiveRecord::Base.connection.execute("ALTER TEXT SEARCH CONFIGURATION search_cfg_en ADD MAPPING FOR version WITH simple;")
    ActiveRecord::Base.connection.execute("ALTER TEXT SEARCH CONFIGURATION search_cfg_en ADD MAPPING FOR asciiword WITH english_stem;")

  end
end