class UpdateImagesAddThumbs < ActiveRecord::Migration
  def change
    add_column :images, :thumb_uid, :string
    add_column :images, :thumb_high_uid, :string
  end
end
