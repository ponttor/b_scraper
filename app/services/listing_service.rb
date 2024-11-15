# frozen_string_literal: true

class ListingService
  class FetchDataError < StandardError; end
  class ParseDataError < StandardError; end
  class ExtractDataError < StandardError; end
  class MetaTagExtractionError < StandardError; end

  SCRAPER_API_URL = 'https://api.scraperapi.com/'

  def initialize(url)
    @url = url
  end

  def retrieve_listing_data
    response = fetch_data_from_external_service
    parsed_body = parse_response(response)
    extract_attributes(parsed_body)
  rescue StandardError => e
    Rails.logger.error("Error in ListingService for URL #{@url}: #{e.message}")
    raise e
  end

  private

  def fetch_data_from_external_service
    params = { 'api_key' => ENV.fetch('API_KEY', nil), 'url' => @url, 'autoparse' => 'true' }
    uri = URI(SCRAPER_API_URL)
    uri.query = URI.encode_www_form(params)

    response = Net::HTTP.get_response(uri)
    unless response.is_a?(Net::HTTPSuccess)
      raise FetchDataError, "ScraperAPI returned an error: #{response.code} #{response.message}"
    end

    response.body
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    raise FetchDataError, "Network request failed: #{e.message}"
  rescue SocketError, Errno::ECONNREFUSED => e
    raise FetchDataError, "Connection error: #{e.message}"
  rescue StandardError => e
    raise FetchDataError, "Unexpected error during external request: #{e.message}"
  end

  def parse_response(response)
    Nokogiri::HTML(response)
  rescue StandardError => e
    raise ParseDataError, "Failed to parse the response: #{e.message}"
  end

  def extract_attributes(parsed_body)
    {
      price: extract_price(parsed_body),
      rating_value: extract_rating_value(parsed_body),
      rating_count: extract_rating_count(parsed_body),
      meta_data: extract_meta_tags(parsed_body)
    }
  rescue StandardError => e
    raise ExtractDataError, "Failed to extract attributes: #{e.message}"
  end

  def extract_price(parsed_body)
    price = parsed_body.css('.price-box__price')[0]&.text&.gsub(/[^\d]/, '')&.strip&.to_i
    raise ExtractDataError, 'Price not found in the response' if price.nil? || price.zero?

    price
  end

  def extract_rating_value(parsed_body)
    parsed_body.css('.ratingValue').first&.text&.tr(',', '.')&.to_f
  end

  def extract_rating_count(parsed_body)
    parsed_body.css('.ratingCount').first&.text&.gsub(/[^\d]/, '')&.to_i
  end

  def extract_meta_tags(parsed_body)
    meta_data = {}

    parsed_body.css('meta').each do |meta_tag|
      name_or_http_equiv = meta_tag['name'] || meta_tag['http-equiv']
      content = meta_tag['content']

      if name_or_http_equiv && content
        meta_data[name_or_http_equiv] = content
      end
    end

    meta_data
  rescue StandardError => e
    raise MetaTagExtractionError, "Failed to extract meta tags: #{e.message}"
  end
end
