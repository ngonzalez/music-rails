class AddIndexes < ActiveRecord::Migration[5.1]
  def change
    [:images, :m3u_files, :sfv_files, :tracks].each do |table_name|
      add_index table_name, :release_id
    end
  end
end