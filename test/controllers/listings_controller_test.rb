require "test_helper"
require "webmock/minitest"

class ListingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @listing = listings(:one)
    @empty_listing = listings(:empty)
    @url = "alza.cz/samsung-dv90bb9545gbs7-d12355019.htm"
    @attrs = {
      url: @url
    }
  end

  test "show" do
    get listing_url(@listing)
    assert_response :success
  end

  test "new" do
    get root_path
    assert_response :success
  end

  test "create" do
    response_data = {
      price: @listing.price,
      rating_value: @listing.rating_value,
      rating_count: @listing.rating_count
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
end
