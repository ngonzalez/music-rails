class AddTsvFields < ActiveRecord::Migration
  def change
    add_column :releases, :tsv_name, :string
    add_column :tracks, :tsv_album, :string
    add_column :tracks, :tsv_artist, :string
    add_column :tracks, :tsv_title, :string
  end
end
