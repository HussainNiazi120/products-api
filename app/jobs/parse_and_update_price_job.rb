# frozen_string_literal: true

class ParseAndUpdatePricesJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false

  def perform(result, asins)
    asins_set = asins.to_set
    result['payload'].each do |item|
      asin = item['ASIN']

      next unless asins_set.include?(asin)

      price = get_price(item.dig('Product', 'CompetitivePricing', 'CompetitivePrices'))

      product = Product.find_by(asin:)
      product&.update(price:, price_updated_at: Time.now)
    end
  end

  private

  def get_price(prices)
    new_price = prices.find { |price| price['condition'] == 'New' }
    new_price&.dig('Price', 'LandedPrice', 'Amount').to_i || 0
  end
end
