class UpdateReleasesAddLabel < ActiveRecord::Migration
  def change
    add_column :releases, :label_name, :string
  end
end