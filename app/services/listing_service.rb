class ListingService
  PROXY = "http://#{ENV['ZENROWS_API_KEY']}:js_render=true&wait_for=.price-box__price&premium_proxy=true&autoparse=true@api.zenrows.com:8001"

  def initialize(url)
    @url = url
  end

  def fetch
    response = fetch_data_from_external_service
    parsed_body = parse_response(response)
    extract_attributes(parsed_body)
  end

  private

  def fetch_data_from_external_service
    conn = Faraday.new(proxy: PROXY, ssl: { verify: false })
    conn.options.timeout = 180

    response = conn.get("https://#{@url}")

    raise "Failed to fetch data. Status: #{response.status}" unless response.success?

    response
  end

  def parse_response(response)
    JSON.parse(response.body)
  rescue JSON::ParserError => e
    raise "Failed to parse response: #{e.message}"
  end

  def extract_attributes(parsed_body)
    commodity_price = parsed_body.find { |listing| listing["data"] && listing["data"]["commodityPrice"] }&.dig("data", "commodityPrice")
    rating_value = parsed_body.dig(1, "aggregateRating", "ratingValue")
    rating_count = parsed_body.dig(1, "aggregateRating", "ratingCount")

    {
      price: commodity_price,
      rating_value: rating_value,
      rating_count: rating_count
    }
  end
end
