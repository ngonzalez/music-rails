class UpdateReleaseAddFolder < ActiveRecord::Migration
  def change
    add_column :releases, :folder, :string
  end
end
