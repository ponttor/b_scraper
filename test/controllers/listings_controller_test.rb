require "test_helper"
require "webmock/minitest"

class ListingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @listing = listings(:full)
    @empty_listing = listings(:empty)
    @url = "alza.cz/samsung-dv90bb9545gbs7-d12355019.htm"
    @attrs = {
      url: @url
    }
  end

  test "show with meta_keys filtering" do
    meta_keys = "description,keywords"
    get listing_url(@listing), params: { meta_keys: meta_keys }
    assert_response :success

    assert_select "strong", text: "Description:"
    assert_select "strong", text: "Keywords:"
    assert_select "strong", text: "Title:", count: 0
  end

  test "show no meta if there is no matching meta_keys" do
    meta_keys = "nonexistent_key"
    get listing_url(@listing), params: { meta_keys: meta_keys }
    assert_response :success

    assert_select "strong", text: "Description:", count: 0
    assert_select "strong", text: "Keywords:", count: 0
  end

  test "show with empty meta_keys" do
    get listing_url(@listing), params: { meta_keys: "" }
    assert_response :success

    assert_select "strong", text: "Description:", count: 0
    assert_select "strong", text: "Keywords:", count: 0
  end

  test "new" do
    get root_path
    assert_response :success
  end

  test "create with meta_data" do
    response_data = {
      price: @listing.price,
      rating_value: @listing.rating_value,
      rating_count: @listing.rating_count,
      meta_data: {
        description: "High-end Samsung dryer",
        keywords: "dryer, Samsung, home appliances"
      }
    }.to_json

    stub_request(:post, @url)
      .to_return(
        status: 200,
        body: response_data,
        headers: { "Content-Type" => "application/json" }
      )

    post listings_url, params: { listing: @attrs }

    listing = Listing.find_by(url: @attrs[:url])

    assert_equal @listing.price, listing.price
    assert_equal @listing.rating_value, listing.rating_value
    assert_equal @listing.rating_count, listing.rating_count

    assert_equal "High-end Samsung dryer", listing.meta_data["description"]
    assert_equal "dryer, Samsung, home appliances", listing.meta_data["keywords"]

    assert_redirected_to listing_url(listing)
  end

  test "should not create with empty URL" do
    post listings_url, params: { listing: { url: "" } }

    assert_response :unprocessable_entity
  end

  test "should not create with invalid url" do
    invalid_attrs = { url: "invalid-url" }

    post listings_url, params: { listing: invalid_attrs }

    assert_response :unprocessable_entity
  end

  test "should not create with valid alza prefix but invalid URL" do
    invalid_url = "alza.cz/invalid-product"
    invalid_attrs = { url: invalid_url }

    stub_request(:get, /api.scraperapi.com/).to_return(
      status: 200,
      body: "<html></html>",
      headers: { "Content-Type" => "text/html" }
    )

    post listings_url, params: { listing: invalid_attrs }

    assert_response :unprocessable_entity

    assert_match "Price not found in the response", response.body
  end
end
