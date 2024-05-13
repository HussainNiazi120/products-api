# frozen_string_literal: true

module Products
  class ShowService < AmzSpApiService
    class MissingAsin < StandardError; end
    class ProductNotFound < StandardError; end

    def initialize(asin)
      raise MissingAsin if asin.blank?

      @asin = asin

      super()
    end

    def call
      product = Product.find_by!(asin: @asin)

      Products::PriceService.call(product) if product.price.nil? || product.price_updated_at < 1.hour.ago

      product
    rescue ActiveRecord::RecordNotFound
      raise ProductNotFound
    end
  end
end
