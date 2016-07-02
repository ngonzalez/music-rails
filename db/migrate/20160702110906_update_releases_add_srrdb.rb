class UpdateReleasesAddSrrdb < ActiveRecord::Migration
  def change
    add_column :releases, :srrdb_sfv_uid, :string
    add_column :releases, :srrdb_sfv_name, :string
  end
end
