class UpdateReleasesRemoveSrrdbFileName < ActiveRecord::Migration
  def change
    remove_column :releases, :srrdb_sfv_name
  end
end
