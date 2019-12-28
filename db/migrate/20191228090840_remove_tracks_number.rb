class RemoveTracksNumber < ActiveRecord::Migration[5.2]
  def change
    remove_column :tracks, :number
  end
end
