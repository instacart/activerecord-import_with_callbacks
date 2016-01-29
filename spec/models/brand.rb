class Brand < ActiveRecord::Base
  has_many :discounts, as: :discountable
  has_many :items, through: :products
  has_many :products
  validates :name, presence: true
  validates :name, uniqueness: true
end
