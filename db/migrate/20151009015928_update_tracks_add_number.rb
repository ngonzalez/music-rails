class UpdateTracksAddNumber < ActiveRecord::Migration
  def change
    add_column :tracks, :number, :string
  end
end