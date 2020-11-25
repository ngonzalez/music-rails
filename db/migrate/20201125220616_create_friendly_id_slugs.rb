class CreateFriendlyIdSlugs < ActiveRecord::Migration[6.0]
  def change
    create_table :friendly_id_slugs do |t|
      t.string :slug, null: false
      t.integer :sluggable_id, null: false
      t.string :sluggable_type, limit: 50
      t.string :scope
      t.datetime :created_at
      t.index [:slug, :sluggable_type, :scope], name: :index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope, unique: true
      t.index [:slug, :sluggable_type], name: :index_friendly_id_slugs_on_slug_and_sluggable_type
      t.index [:sluggable_id], name: :index_friendly_id_slugs_on_sluggable_id
      t.index [:sluggable_type], name: :index_friendly_id_slugs_on_sluggable_type
    end
  end
end
