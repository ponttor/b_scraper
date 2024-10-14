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
    @listing = Listing.find_or_initialize_by(url: url)

    raise InvalidUrlError, "URL must start with 'alza.cz/'" unless url.start_with?("alza.cz/")
    return redirect_to listing_url(@listing, meta_keys: listing_params[:meta_keys]) if @listing.persisted?

    listing_data = ListingService.new(url).fetch
    assign_listing_attributes(listing_data)

    if @listing.save
      redirect_to listing_url(@listing, meta_keys: listing_params[:meta_keys]), flash: { success: "Success!" }
    else
      flash.now[:error] = @listing.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end

  rescue StandardError => e
    flash.now[:error] = e.message
    render :new, status: :unprocessable_entity
  end

  private

  def listing_params
    params.require(:listing).permit(:url, :meta_keys)
  end

  def assign_listing_attributes(listing_data)
    @listing.assign_attributes(
      price: listing_data[:price],
      meta_data: listing_data[:meta_data],
      rating_value: listing_data[:rating_value],
      rating_count: listing_data[:rating_count],
    )
  end

  def filter_meta_data(meta_data)
    meta_keys = parse_meta_keys

    meta_data.select { |key, _| meta_keys.include?(key) }
  end

  def parse_meta_keys
    params[:meta_keys]
      .to_s
      .split(",")
      .map(&:strip)
      .reject(&:blank?)
  end
end
