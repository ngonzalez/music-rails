class ReleasesAddDataUrl < ActiveRecord::Migration[5.1]
  def change
    add_column :releases, :data_url, :string
    add_index :releases, :data_url, unique: true
  end
end