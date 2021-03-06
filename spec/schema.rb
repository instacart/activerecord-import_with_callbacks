ActiveRecord::Schema.define do
  create_table :brands, force: :cascade do |t|
    t.string :name, null: false
  end

  create_table :discounts, force: :cascade do |t|
    t.integer :discountable_id
    t.string :discountable_type
    t.integer :percent_off
  end

  create_table :items, force: :cascade do |t|
    t.integer :product_id, null: false
    t.integer :price, null: false
  end

  create_table :products, force: :cascade do |t|
    t.integer :brand_id, null: false
    t.string :name, null: false
  end
end
