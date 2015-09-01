class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.string :file_uid, null: false
      t.string :file_name, null: false
    end
  end
end