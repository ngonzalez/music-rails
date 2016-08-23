class UpdateReleaseRemoveSfvUid < ActiveRecord::Migration
  def change
    remove_column :releases, :sfv_uid
    remove_column :releases, :srrdb_sfv_uid
  end
end
