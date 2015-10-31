class UpdateReleasesAddYearAndFormatName < ActiveRecord::Migration
  def change
    add_column :releases, :year, :string
    add_column :releases, :format_name, :string
  end
end