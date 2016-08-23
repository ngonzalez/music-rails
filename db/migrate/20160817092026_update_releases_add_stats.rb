class UpdateReleasesAddStats < ActiveRecord::Migration
  def change
    add_column :releases, :folder_created_at, :datetime
    add_column :releases, :folder_updated_at, :datetime
  end
end
