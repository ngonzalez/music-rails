class AddDeletedAt < ActiveRecord::Migration
  def change
    add_column :releases, :deleted_at, :datetime
    add_column :tracks, :deleted_at, :datetime
    add_column :uploads, :deleted_at, :datetime
    add_column :images, :deleted_at, :datetime
  end
end