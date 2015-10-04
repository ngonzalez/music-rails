class UpdateTracksAddState < ActiveRecord::Migration
  def change
    add_column :tracks, :state, :string
  end
end