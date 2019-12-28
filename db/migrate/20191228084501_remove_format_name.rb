class RemoveFormatName < ActiveRecord::Migration[5.2]
  def change
    remove_column :releases, :format_name
    remove_column :tracks, :format_name
  end
end
