# frozen_string_literal: true

class ScrapListingDataJob < ApplicationJob
  queue_as :default

  def perform(url)
    ScrapListingDataService.new(url).call
  rescue StandardError => e
    Rails.logger.error("Error in ScrapListingDataJob for URL #{url}: #{e.message}")
  end
end
