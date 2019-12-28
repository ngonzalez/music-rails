class UpdateLocalFilesAddBasePath < ActiveRecord::Migration[5.2]
  def change
    add_column :m3u_files, :base_path, :string
    add_column :sfv_files, :base_path, :string
  end
end
