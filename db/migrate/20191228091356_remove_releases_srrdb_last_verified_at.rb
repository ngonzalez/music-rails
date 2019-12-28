class RemoveReleasesSrrdbLastVerifiedAt < ActiveRecord::Migration[5.2]
  def change
    remove_column :releases, :srrdb_last_verified_at
  end
end
