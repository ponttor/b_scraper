# frozen_string_literal: true

require 'test_helper'
require 'webmock/minitest'

class ListingServiceTest < ActiveSupport::TestCase
  setup do
    @url = 'https://www.alza.cz/some-product'
    @service = ListingService.new(@url)
    @response_data = <<-HTML
      <html>
        <div class="price-box__price">1 500 CZK</div>
        <div class="ratingCount">320</div>
        <div class="ratingValue">4.7</div>
        <meta name="description" content="Product description">
        <meta name="keywords" content="product, test">
      </html>
    HTML
  end

  test 'successfully fetches and parses data' do
    stub_request(:get, /api.scraperapi.com/).to_return(
      status: 200,
      body: @response_data,
      headers: { 'Content-Type' => 'text/html' }
    )

    result = @service.retrieve_listing_data

    assert_equal 1500, result[:price]
    assert_equal 320, result[:rating_count]
    assert_equal 4.7, result[:rating_value]
    assert_equal 'Product description', result[:meta_data]['description']
    assert_equal 'product, test', result[:meta_data]['keywords']
  end

  test 'handles network errors gracefully' do
    stub_request(:get, /api.scraperapi.com/).to_timeout

    assert_raises(ListingService::FetchDataError) do
      @service.retrieve_listing_data
    end
  end

  # Некорректный ответ от внешнего сервиса (ошибка HTTP)
  test 'handles non-successful HTTP responses' do
    stub_request(:get, /api.scraperapi.com/).to_return(status: 500)

    assert_raises(ListingService::FetchDataError) do
      @service.retrieve_listing_data
    end
  end

  # Ошибка парсинга HTML
  test 'raises ParseDataError when response cannot be parsed' do
    stub_request(:get, /api.scraperapi.com/).to_return(
      status: 200,
      body: 'Invalid HTML',
      headers: { 'Content-Type' => 'text/html' }
    )

    assert_raises(ListingService::ParseDataError) do
      @service.retrieve_listing_data
    end
  end

  # Ошибка при извлечении данных: цена не найдена
  test 'raises ExtractDataError when price is missing or invalid' do
    response_without_price = <<-HTML
      <html>
        <div class="ratingCount">320</div>
        <div class="ratingValue">4.7</div>
        <meta name="description" content="Product description">
        <meta name="keywords" content="product, test">
      </html>
    HTML

    stub_request(:get, /api.scraperapi.com/).to_return(
      status: 200,
      body: response_without_price,
      headers: { 'Content-Type' => 'text/html' }
    )

    assert_raises(ListingService::ExtractDataError) do
      @service.retrieve_listing_data
    end
  end

  # Ошибка при извлечении мета-тегов
  test 'raises MetaTagExtractionError when meta tags cannot be extracted' do
    invalid_response = <<-HTML
      <html>
        <div class="price-box__price">1 500 CZK</div>
        <div class="ratingCount">320</div>
        <div class="ratingValue">4.7</div>
      </html>
    HTML

    stub_request(:get, /api.scraperapi.com/).to_return(
      status: 200,
      body: invalid_response,
      headers: { 'Content-Type' => 'text/html' }
    )

    result = @service.retrieve_listing_data

    assert_empty result[:meta_data], 'Meta data should be empty if no meta tags found'
  end
end