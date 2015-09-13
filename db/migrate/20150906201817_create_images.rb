class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.integer :release_id, null: false
      t.string :file_uid, null: false
      t.string :file_name, null: false
    end
  end
end