class UpdateReleasesRemoveSfvName < ActiveRecord::Migration
  def change
    remove_column :releases, :sfv_name
  end
end
