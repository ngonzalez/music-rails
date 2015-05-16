class RemoveTsvFields < ActiveRecord::Migration
  def change
    remove_column :releases, :tsv_name
    remove_column :tracks, :tsv_album
    remove_column :tracks, :tsv_artist
    remove_column :tracks, :tsv_title
  end
end
