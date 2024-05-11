# frozen_string_literal: true

module Products
  class SearchService < AmzSpApiService
    class MissingKeywords < StandardError; end

    INCLUDED_DATA = %w[attributes images relationships].freeze
    PAGE_SIZE = 20

    def initialize(keywords, variation_asins = [])
      raise MissingKeywords if keywords.blank?

      @keywords = [keywords]
      @variation_asins = variation_asins

      super()
    end

    def call
      Rails.cache.fetch("/api/products?keywords=#{@keywords}", expires_in: 1.hour) do
        api = AmzSpApi::CatalogItemsApiModel::CatalogApi.new(AmzSpApi::SpApiClient.new)
        result = api.search_catalog_items(MARKET_PLACE_IDS,
                                          { keywords: @keywords,
                                            included_data: INCLUDED_DATA,
                                            page_size: PAGE_SIZE })

        Products::ParseSearchResultService.call(result.as_json, @variation_asins)
      end
    rescue AmzSpApi::ApiError => e
      puts "Exception when calling SP-API: #{e}"
    end
  end
end
