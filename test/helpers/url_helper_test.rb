require "test_helper"

class UrlHelperTest < ActionView::TestCase
  include UrlHelper

  test "clean_url handles URL with http" do
    url = "http://www.alza.cz/product/123"
    assert_equal "alza.cz/product/123", clean_url(url)
  end

  test "clean_url handles URL with https" do
    url = "https://www.alza.cz/product/123"
    assert_equal "alza.cz/product/123", clean_url(url)
  end

  test "clean_url handles URL without scheme" do
    url = "www.alza.cz/product/123"
    assert_equal "alza.cz/product/123", clean_url(url)
  end

  test "clean_url handles URL without www" do
    url = "alza.cz/product/123"
    assert_equal "alza.cz/product/123", clean_url(url)
  end

  test "clean_url handles URL without path" do
    url = "https://www.alza.cz"
    assert_equal "alza.cz", clean_url(url)
  end
end
