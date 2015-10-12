class UpdateTracksRenameState < ActiveRecord::Migration
  def change
    rename_column :tracks, :state, :process_id
  end
end