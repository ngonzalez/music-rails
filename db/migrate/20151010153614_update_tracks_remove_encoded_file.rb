class UpdateTracksRemoveEncodedFile < ActiveRecord::Migration
  def change
    remove_column :tracks, :encoded_file_uid
    remove_column :tracks, :encoded_file_name
  end
end