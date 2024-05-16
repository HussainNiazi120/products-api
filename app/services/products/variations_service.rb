# frozen_string_literal: true

module Products
  class VariationsService < AmzSpApiService
    class MissingAsin < StandardError; end
    class ProductNotFound < StandardError; end

    def initialize(asin)
      raise MissingAsin if asin.blank?

      @asin = asin

      super()
    end

    def call
      product = Product.find_by!(asin: @asin)
      return [] unless product.parent_asin.present?
      return product.variation_asins if product.variation_asins.present? && (product.product_updated_at.nil? || product.product_updated_at < 1.week.ago)

      child_asins = find_child_asins(product)

      GetChildProductsJob.perform_later(child_asins)

      child_asins
    rescue ActiveRecord::RecordNotFound
      raise ProductNotFound
    end

    private

    def find_child_asins(product)
      parent_product = Product.find_by(asin: product.parent_asin)
      if parent_product
        parent_product.child_asins
      else
        parent_product = Products::SearchService.call(product.parent_asin).first
        parent_product[:child_asins]
      end
    end
  end
end
