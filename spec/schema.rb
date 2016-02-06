ActiveRecord::Schema.define do
  create_table :brands, force: :cascade do |t|
    t.string :name, null: false
  end
end
