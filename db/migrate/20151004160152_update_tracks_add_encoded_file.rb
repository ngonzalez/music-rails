class UpdateTracksAddEncodedFile < ActiveRecord::Migration
  def change
    add_column :tracks, :encoded_file_uid, :string
    add_column :tracks, :encoded_file_name, :string
  end
end