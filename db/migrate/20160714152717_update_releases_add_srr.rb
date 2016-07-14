class UpdateReleasesAddSrr < ActiveRecord::Migration
  def change
    add_column :releases, :srrdb_srr_uid, :string
  end
end
