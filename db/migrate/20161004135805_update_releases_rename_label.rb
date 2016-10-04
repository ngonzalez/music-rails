class UpdateReleasesRenameLabel < ActiveRecord::Migration
  def change
    rename_column :releases, :label_name, :subfolder
  end
end
