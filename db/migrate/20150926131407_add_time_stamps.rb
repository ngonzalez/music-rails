class AddTimeStamps < ActiveRecord::Migration
  def change
    add_column :releases, :created_at, :datetime
    add_column :releases, :updated_at, :datetime
    add_column :tracks, :created_at, :datetime
    add_column :tracks, :updated_at, :datetime
    add_column :images, :created_at, :datetime
    add_column :images, :updated_at, :datetime
    add_column :uploads, :created_at, :datetime
    add_column :uploads, :updated_at, :datetime
  end
end