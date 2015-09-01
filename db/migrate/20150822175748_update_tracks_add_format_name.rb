class UpdateTracksAddFormatName < ActiveRecord::Migration
  def change
    add_column :tracks, :format_name, :string
    add_index :tracks, :format_name
  end
end
