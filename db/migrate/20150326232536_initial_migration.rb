class InitialMigration < ActiveRecord::Migration
  def change
    create_table :releases do |t|
      t.string :name, null: false, unique: true
    end

    create_table :tracks do |t|
      t.integer :release_id, null: false
      t.string :name, null: false, unique: true
      t.string :format, null: false

      t.string :artist
      t.string :title
      t.string :album
      t.string :genre
      t.string :year

      t.integer :bitrate
      t.integer :channels
      t.integer :length
      t.integer :sample_rate
    end

    add_index :releases, :name

    add_index :tracks, :name
    add_index :tracks, :artist
    add_index :tracks, :title
    add_index :tracks, :album
    add_index :tracks, :genre
    add_index :tracks, :year

  end
end