class UpdateReleases < ActiveRecord::Migration[5.1]
  def change
    add_index :releases, :name, unique: true
  end
end
