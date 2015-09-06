class UpdateTracksAddLastVerifiedAt < ActiveRecord::Migration
  def change
    add_column :releases, :last_verified_at, :datetime
  end
end