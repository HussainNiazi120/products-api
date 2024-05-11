# frozen_string_literal: true

class UpdateProductsJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false

  def perform(products, variation_asins)
    Product.upsert_all(products, unique_by: :asin)

    Product.where(asin: variation_asins).update_all(variation_asins:)
  end
end
