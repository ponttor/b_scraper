class ListingService
  class FetchDataError < StandardError; end
  class ParseDataError < StandardError; end

  SCRAPER_API_URL = "https://api.scraperapi.com/"

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
  rescue StandardError => e
    raise FetchDataError, "External request failed: #{e.message}"
  end

  def parse_response(response)
    Nokogiri::HTML(response)
  rescue StandardError => e
    raise ParseDataError, "Failed to parse response: #{e.message}"
  end

  def extract_attributes(parsed_body)
    price = parsed_body.css(".price-box__price")[0]&.text&.gsub(/[^\d]/, "").strip&.to_i
    rating_count = parsed_body.css(".ratingCount").first&.text&.gsub(/[^\d]/, "")&.to_i
    rating_value = parsed_body.css(".ratingValue").first&.text&.gsub(",", ".")&.to_f

    meta_data = extract_meta_tags(parsed_body)

    {
      price: price,
      rating_value: rating_value,
      rating_count: rating_count,
      meta_data: meta_data
    }
  end

  def extract_meta_tags(parsed_body)
    meta_data = {}

    parsed_body.css("meta").each do |meta_tag|
      name_or_http_equiv = meta_tag["name"] || meta_tag["http-equiv"]
      content = meta_tag["content"]

      if name_or_http_equiv && content
        meta_data[name_or_http_equiv] = content
      end
    end

    meta_data
  end
end
