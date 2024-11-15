# frozen_string_literal: true

class ListingsIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @valid_url = 'alza.cz/test-product'
    @invalid_url = 'https://invalid.product'
    @existing_listing = listings(:full)
  end

  test 'should create listing with valid URL and background job' do
    stub_request(:get, /api.scraperapi.com/).to_return(
      status: 200,
      body: {
        price: 100,
        rating_value: 4.5,
        rating_count: 10,
        meta_data: { description: 'Test product', keywords: 'test' }
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

    post listings_url, params: { listing: { url: @valid_url } }

    assert_enqueued_with(job: ScrapListingDataJob)
    assert_redirected_to root_path
    follow_redirect!
    assert_match 'Listing is being processed!', response.body
  end

  test 'should not create listing with invalid URL format' do
    post listings_url, params: { listing: { url: @invalid_url } }
    assert_response :unprocessable_entity
    assert_match "URL must start with 'alza.cz/'", response.body
  end

  test 'should return cached data if listing is already cached' do
    $redis.set(@valid_url, @existing_listing.to_json)
    post listings_url, params: { listing: { url: @valid_url } }
    assert_redirected_to listing_url(@existing_listing)
  end

  test 'should return existing listing if it is already in the database' do
    post listings_url, params: { listing: { url: @existing_listing.url } }
    assert_redirected_to listing_url(@existing_listing)
    assert_no_enqueued_jobs
  end
end
