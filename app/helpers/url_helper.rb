# frozen_string_literal: true

module UrlHelper
  def clean_url(url)
    parsed_url = URI.parse(url)
    parsed_url = URI.parse("http://#{url}") if parsed_url.scheme.nil?
    "#{parsed_url.host.sub(/^www\./, '')}#{parsed_url.path}"
  end
end
