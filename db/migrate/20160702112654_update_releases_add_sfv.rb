class UpdateReleasesAddSfv < ActiveRecord::Migration
  def change
    add_column :releases, :sfv_uid, :string
    add_column :releases, :sfv_name, :string
  end
end
