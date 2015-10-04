class UpdateTracksAddFile < ActiveRecord::Migration
  def change
    add_column :tracks, :file_uid, :string
    add_column :tracks, :file_name, :string
  end
end