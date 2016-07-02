class UpdateReleasesAddSrrdbLastVerifiedAt < ActiveRecord::Migration
  def change
    add_column :releases, :srrdb_last_verified_at, :datetime
  end
end
