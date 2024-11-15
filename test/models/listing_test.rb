# frozen_string_literal: true

# test/models/listing_test.rb

require 'test_helper'

class ListingTest < ActiveSupport::TestCase
  setup do
    @listing = listings(:full)
  end

  test 'should not save listing without url' do
    listing = Listing.new(price: 100, rating_value: 4.5, rating_count: 10)
    assert_not listing.save
  end

  test 'should not save listing with invalid url' do
    listing = Listing.new(url: 'invalid-url', price: 100, rating_value: 4.5, rating_count: 10)
    assert_not listing.save
  end

  test 'should save valid listing' do
    listing = Listing.new(url: 'https://alza.cz/test-product', price: 100, rating_value: 4.5, rating_count: 10)
    assert listing.save
  end

  test 'should not save listing with negative price' do
    listing = Listing.new(url: 'https://alza.cz/test-product', price: -100)
    assert_not listing.save
  end

  test 'should not save listing with rating value out of range' do
    listing = Listing.new(url: 'https://alza.cz/test-product', rating_value: 6)
    assert_not listing.save
  end

  test 'should filter meta_data correctly' do
    filtered_meta_data = @listing.meta_data.select { |key, _| %w[description keywords].include?(key) }
    assert_equal 2, filtered_meta_data.keys.size
  end
end
