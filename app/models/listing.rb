# frozen_string_literal: true

class Listing < ApplicationRecord
  MIN_RATING = 0
  MAX_RATING = 5

  attr_accessor :meta_keys

  validates :url, presence: true, uniqueness: true

  validates :price, numericality: { greater_than: 0, allow_nil: true, message: 'Price must be greater than 0' }
  validates :rating_value, numericality: { greater_than_or_equal_to: MIN_RATING, less_than_or_equal_to: MAX_RATING, allow_nil: true, message: 'Rating must be between 0 and 5' }
  validates :rating_count, numericality: { greater_than_or_equal_to: 0, allow_nil: true, message: 'Review count cannot be negative' }

  validate :validate_url

  def validate_url
    errors.add(:url, 'Invalid url') unless PublicSuffix.valid?(url) && url.start_with?('alza.cz/')
  end
end
