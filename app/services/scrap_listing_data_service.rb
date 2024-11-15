# frozen_string_literal: true

class ScrapListingDataService
  def initialize(url)
    @url = url
  end

  def call
    listing_data = ListingService.new(@url).retrieve_listing_data
    create_or_update_listing(listing_data)
  rescue StandardError => e
    Rails.logger.error("Error fetching or saving listing data for URL #{@url}: #{e.message}")
    raise e
  end

  private

  def create_or_update_listing(listing_data)
    listing = find_or_initialize_listing
    assign_listing_attributes(listing, listing_data)
    save_listing(listing)
  end

  def find_or_initialize_listing
    Listing.find_or_initialize_by(url: @url)
  end

  def assign_listing_attributes(listing, listing_data)
    listing.assign_attributes(
      price: listing_data[:price],
      meta_data: listing_data[:meta_data],
      rating_value: listing_data[:rating_value],
      rating_count: listing_data[:rating_count]
    )
  end

  def save_listing(listing)
    listing.save!
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Database validation failed for listing #{listing.url}: #{e.message}")
    raise e
  rescue ActiveRecord::RecordNotUnique => e
    Rails.logger.error("Duplicate record error for listing #{listing.url}: #{e.message}")
    raise e
  rescue ActiveRecord::ActiveRecordError => e
    Rails.logger.error("Unexpected database error for listing #{listing.url}: #{e.message}")
    raise e
  end
end
