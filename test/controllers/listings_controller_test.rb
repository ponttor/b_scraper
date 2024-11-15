# frozen_string_literal: true

require 'test_helper'
require 'webmock/minitest'

class ListingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @listing = listings(:full)
    @url = 'alza.cz/test-product'
    @invalid_url = 'invalid-url'
    @attrs = {
      url: @url
    }
  end

  test 'show with meta_keys filtering' do
    meta_keys = 'description,keywords'
    get listing_url(@listing), params: { meta_keys: }
    assert_response :success

    assert_select 'strong', text: 'Description:'
    assert_select 'strong', text: 'Keywords:'
    assert_select 'strong', text: 'Title:', count: 0
  end

  test 'show no meta if there is no matching meta_keys' do
    meta_keys = 'nonexistent_key'
    get listing_url(@listing), params: { meta_keys: }
    assert_response :success

    assert_select 'strong', text: 'Description:', count: 0
    assert_select 'strong', text: 'Keywords:', count: 0
  end

  test 'show with empty meta_keys' do
    get listing_url(@listing), params: { meta_keys: '' }
    assert_response :success

    assert_select 'strong', text: 'Description:', count: 0
    assert_select 'strong', text: 'Keywords:', count: 0
  end

  test 'new' do
    get root_path
    assert_response :success
  end

  test 'create with meta_data' do
    Rails.cache.clear
    response_body = <<-HTML
      <html>
        <div class="price-box__price">1 500 CZK</div>
        <div class="ratingCount">320</div>
        <div class="ratingValue">4.7</div>
        <meta name="description" content="Product description">
        <meta name="keywords" content="product, test">
      </html>
    HTML

    stub_request(:get, 'https://api.scraperapi.com/?api_key&autoparse=true&url=alza.cz/test-product')
      .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'text/html' })

    post listings_url, params: { listing: @attrs }

    listing = Listing.find_by(url: @attrs[:url])
    assert_equal @listing.price, listing.price
    assert_equal @listing.rating_value, listing.rating_value
    assert_equal @listing.rating_count, listing.rating_count

    assert_equal 'Product description', listing.meta_data['description']
    assert_equal 'product, test', listing.meta_data['keywords']

    assert_redirected_to root_url
  end

  test 'should return cached data if listing is already cached' do
    Rails.cache.write(@url, @listing)

    post listings_url, params: { listing: { url: @url } }

    listing = assigns(:listing)

    assert_equal @listing['price'], listing['price']
    assert_equal @listing['rating_value'], listing['rating_value']
    assert_equal @listing['rating_count'], listing['rating_count']
    assert_equal @listing['meta_data']['description'], listing['meta_data']['description']

    assert_no_enqueued_jobs
  end

  test 'should return existing listing if it is already in the database' do
    post listings_url, params: { listing: { url: @listing.url } }
    assert_redirected_to listing_url(@listing)

    listing = assigns(:listing)

    assert_equal listing['price'], @listing['price']
    assert_equal listing['rating_value'], @listing['rating_value']
    assert_equal listing['rating_count'], @listing['rating_count']
    assert_equal listing['meta_data']['description'], @listing['meta_data']['description']

    assert_no_enqueued_jobs
  end

  test 'should not create with empty URL' do
    post listings_url, params: { listing: { url: '' } }
    assert_response :unprocessable_entity
  end

  test 'should not create with invalid url format' do
    post listings_url, params: { listing: { url: @invalid_url } }
    assert_response :unprocessable_entity
  end

  # test 'should create listing and enqueue job if not in cache or database' do

  # end

  # test 'should handle Redis errors gracefully' do

  # end
end
