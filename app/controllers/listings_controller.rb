class ListingsController < ApplicationController
  def show
    @listing = Listing.find(params[:id])
  end

  def new
    @listing = Listing.new
  end

  def create
    url = clean_url(listing_params[:url])

    @listing = Listing.find_or_initialize_by(url: url)

    raise StandardError, "URL must start with 'alza.cz/'" unless url.start_with?("alza.cz/")

    return redirect_to listing_url(@listing) if @listing.persisted?
    listing_data = ListingService.new(url).fetch
    assign_listing_attributes(listing_data)

    if @listing.save
      redirect_to listing_url(@listing), flash: { success: "Listing successfully created!" }
    else
      flash.now[:error] = @listing.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end

  rescue StandardError => e
    # @listing ||= Listing.new
    flash.now[:error] = e.message
    render :new, status: :unprocessable_entity
  end

  private

  def listing_params
    params.require(:listing).permit(:url)
  end

  def clean_url(url)
    parsed_url = URI.parse(url)
    parsed_url = URI.parse("http://#{url}") if parsed_url.scheme.nil?

    "#{parsed_url.host.sub(/^www\./, '')}#{parsed_url.path}"
  end

  def assign_listing_attributes(listing_data)
    @listing.assign_attributes(
      price: listing_data[:price],
      rating_value: listing_data[:rating_value],
      rating_count: listing_data[:rating_count],
    )
  end
end
