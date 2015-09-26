class UpdateReleasesAddFormattedName < ActiveRecord::Migration
  def change
    add_column :releases, :formatted_name, :string
  end
end