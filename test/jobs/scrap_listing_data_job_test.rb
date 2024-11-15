# frozen_string_literal: true

# test/jobs/fetch_listing_data_job_test.rb

require 'test_helper'

class ScrapListingDataJobTest < ActiveJob::TestCase
  setup do
    @url = 'https://alza.cz/test-product'
    ActiveJob::Base.queue_adapter = :test
  end

  # test 'job is enqueued' do
  #   assert_enqueued_with(job: ScrapListingDataJob) do
  #     ScrapListingDataJob.perform_later(@url)
  #   end
  # end

  test 'job performs correctly' do
    response_data = {
      price: 100,
      rating_value: 4.5,
      rating_count: 10,
      meta_data: {
        description: 'Test product description',
        keywords: 'test, product'
      }
    }

    stub_request(:get, @url).to_return(
      status: 200,
      body: response_data.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

    assert_performed_jobs 1 do
      ScrapListingDataJob.perform_now(@url)
    end
  end
end
