class ListingService
  SCRAPER_API_URL = "https://api.scraperapi.com/"
  PROXY = "http://#{ENV['ZENROWS_API_KEY']}:js_render=true&wait_for=.price-box__price&premium_proxy=true&proxy_country=cz&autoparse=true@api.zenrows.com:8001"

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
    params = { "api_key" => ENV["API_KEY"], "url" => @url, "autoparse" => "true" }
    uri = URI(SCRAPER_API_URL)
    uri.query = URI.encode_www_form(params)

    Net::HTTP.get(uri)
  rescue Faraday::Error => e
    raise FetchDataError, "External request failed: #{e.message}"
  end

  def parse_response(response)
    Nokogiri::HTML(response)
  rescue JSON::ParserError => e
    raise "Failed to parse response: #{e.message}"
  end

  def extract_attributes(parsed_body)
    price = parsed_body.css(".price-box__price")[0]&.text&.gsub(/[^\d]/, "").strip&.to_i
    rating_count = parsed_body.css(".ratingCount").first&.text&.gsub(/[^\d]/, "")&.to_i
    rating_value = parsed_body.css(".ratingValue").first&.text&.gsub(",", ".")&.to_f

    {
      price: price,
      rating_value: rating_value,
      rating_count: rating_count
    }
  end
end
