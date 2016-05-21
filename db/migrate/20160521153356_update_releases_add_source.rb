class UpdateReleasesAddSource < ActiveRecord::Migration
  def change
    add_column :releases, :source, :string
  end
end
