class Item < ActiveRecord::Base
  belongs_to :product
  has_many :discounts, as: :discountable
  validates :price, presence: true
end
