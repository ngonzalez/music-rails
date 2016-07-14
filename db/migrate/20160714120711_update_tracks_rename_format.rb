class UpdateTracksRenameFormat < ActiveRecord::Migration
  def change
    rename_column :tracks, :format, :format_info
  end
end
