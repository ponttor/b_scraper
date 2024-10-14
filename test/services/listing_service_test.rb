require "test_helper"
require "webmock/minitest"

class ListingServiceTest < ActiveSupport::TestCase
  setup do
    @url = "https://www.alza.cz/some-product"
    @service = ListingService.new(@url)
    @response_data = <<-HTML
      <html>
        <div class="price-box__price">1 500 CZK</div>
        <div class="ratingCount">320</div>
        <div class="ratingValue">4.7</div>
        <meta name="description" content="Product description">
        <meta name="keywords" content="product, test">
      </html>
    HTML
  end

  test "successfully fetches and parses data" do
    stub_request(:get, /api.scraperapi.com/).to_return(
      status: 200,
      body: @response_data,
      headers: { "Content-Type" => "text/html" }
    )

    result = @service.fetch

    assert_equal 1500, result[:price]
    assert_equal 320, result[:rating_count]
    assert_equal 4.7, result[:rating_value]
    assert_equal "Product description", result[:meta_data]["description"]
    assert_equal "product, test", result[:meta_data]["keywords"]
  end
end
