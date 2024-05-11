# frozen_string_literal: true

module Products
  class PriceService < AmzSpApiService
    MARKET_PLACE_ID = MARKET_PLACE_IDS.first
    ITEM_TYPE = 'Asin'
    ITEM_CONDITION = 'New'

    def initialize(product)
      @product = product

      super()
    end

    def call
      offers = item_offers.as_json.first.second.dig('Summary', 'LowestPrices')
      offer, is_prime = find_offer(offers)

      update_product_price(offer, is_prime) if offer
    rescue AmzSpApi::ApiError => e
      puts "Exception when calling SP-API: #{e}"
    end

    private

    def find_offer(offers)
      amazon_new = offers.find { |offer| offer['condition'] == 'new' && offer['fulfillmentChannel'] == 'Amazon' }
      non_amazon_new = offers.find { |offer| offer['condition'] == 'new' && offer['fulfillmentChannel'] == 'Merchant' }

      if amazon_new
        [amazon_new, true]
      elsif non_amazon_new
        [non_amazon_new, false]
      else
        [nil, nil]
      end
    end

    def update_product_price(offer, is_prime)
      price_dollars = offer&.dig('LandedPrice', 'Amount') || nil
      price_cents = (price_dollars.to_f * 100).to_i if price_dollars

      @product.update!(price: price_cents, price_updated_at: Time.now, is_prime:) if price_cents
    end

    def item_offers
      api = AmzSpApi::ProductPricingApiModel::ProductPricingApi.new(AmzSpApi::SpApiClient.new)
      api.get_item_offers(MARKET_PLACE_ID, ITEM_CONDITION, @product.asin, {})
    end
  end
end
