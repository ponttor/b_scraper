# frozen_string_literal: true

class ListingsController < ApplicationController
  class InvalidUrlError < StandardError; end

  def show
    @listing = Listing.find(params[:id])
    @filtered_meta_data = filter_meta_data(@listing.meta_data)
  end

  def new
    @listing = Listing.new
  end

  def create
    url = clean_url(listing_params[:url])
    raise InvalidUrlError, "URL must start with 'alza.cz/'" unless url.start_with?('alza.cz/')

    @listing = fetch_or_cache_listing(url)

    if @listing
      return redirect_to listing_url(@listing, meta_keys: listing_params[:meta_keys])
    end

    flash[:success] = 'Listing is being processed!'
    redirect_to root_path
  rescue StandardError => e
    @listing = Listing.new
    flash.now[:danger] = e.message
    render :new, status: :unprocessable_entity
  end

  private

  def listing_params
    params.require(:listing).permit(:url, :meta_keys)
  end

  def filter_meta_data(meta_data)
    meta_keys = parse_meta_keys

    meta_data.select { |key, _| meta_keys.include?(key) }
  end

  def fetch_or_cache_listing(url)
    Rails.cache.fetch(url, expires_in: 12.hours) do
      listing = Listing.find_or_initialize_by(url:)

      if listing.persisted?
        listing
      else
        ScrapListingDataJob.perform_later(url)
        nil
      end
    end
  end

  def parse_meta_keys
    params[:meta_keys]
      .to_s
      .split(',')
      .map(&:strip)
      .compact_blank
  end
end
