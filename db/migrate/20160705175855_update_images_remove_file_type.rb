class UpdateImagesRemoveFileType < ActiveRecord::Migration
  def change
    remove_column :images, :file_type
  end
end
