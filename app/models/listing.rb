class Listing < ApplicationRecord
  validates :url, presence: true, uniqueness: true

  validates :price, numericality: { allow_nil: true }
  validates :rating_value, numericality: { allow_nil: true }
  validates :rating_count, numericality: { allow_nil: true }
end
