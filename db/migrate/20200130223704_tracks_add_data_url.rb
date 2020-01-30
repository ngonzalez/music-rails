class TracksAddDataUrl < ActiveRecord::Migration[6.0]
  def change
    add_column :tracks, :data_url, :string
    add_index :tracks, :data_url, unique: true
  end
end
