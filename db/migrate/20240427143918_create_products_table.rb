# frozen_string_literal: true

class CreateProductsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :asin, null: false
      t.string :brand
      t.string :name
      t.float :length
      t.float :width
      t.float :height
      t.float :weight
      t.jsonb :images
      t.jsonb :bullet_points
      t.text :description
      t.integer :price
      t.datetime :price_updated_at
      t.boolean :is_prime
      t.datetime :product_updated_at
      t.string :location
      t.string :parent_asin
      t.jsonb :child_asins
      t.jsonb :variation_asins

      t.timestamps
    end

    add_index :products, :asin, unique: true
  end
end
