class UpdateReleasesAddDetails < ActiveRecord::Migration
  def change
    add_column :releases, :details, :text
  end
end