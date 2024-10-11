class ListingsController < ApplicationController
  def show
    @listing = Listing.find(params[:id])
  end

  def new
    @listing = Listing.new
  end

  def create
    clean_url = clean_url(listing_params[:url])
    @listing = Listing.find_or_initialize_by(url: clean_url)

    unless @listing.persisted?
      listing_data = ListingService.new(clean_url).fetch

      @listing.assign_attributes(
        price: listing_data[:price],
        rating_value: listing_data[:rating_value] || 0,
        rating_count: listing_data[:rating_count] || 0,
      )
    end

    if @listing.save
      redirect_to listing_url(@listing), flash: { success: "Listing successfully created!" }
    else
      render :new, status: :unprocessable_entity
    end

  rescue StandardError => e
    flash.now[:error] = "An error occurred: #{e.message}"
    render :new, status: :unprocessable_entity
  end

  private

  def listing_params
    params.require(:listing).permit(:url)
  end

  def clean_url(url)
    parsed_url = URI.parse(url)
    parsed_url = URI.parse("http://#{url}") if parsed_url.scheme.nil?

    "#{parsed_url.host}#{parsed_url.path}"
  end
end
