class RemoveTracksProcessId < ActiveRecord::Migration[5.2]
  def change
    remove_column :tracks, :process_id
  end
end
