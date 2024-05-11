# frozen_string_literal: true

module Products
  class ParseSearchResultService < ApplicationService
    def initialize(result, variation_asins = [])
      @result = result
      @variation_asins = variation_asins

      super()
    end

    def call
      products = []

      @result['items'].each do |item|
        product = build_product(item)
        products << product
      end

      UpdateProductsJob.perform_later(products, @variation_asins)

      products
    end

    private

    def build_product(item)
      {
        asin: item['asin'],
        brand: extract_attribute(item, 'brand'),
        name: extract_attribute(item, 'item_name'),
        length: extract_dimension(item, 'length'),
        width: extract_dimension(item, 'width'),
        height: extract_dimension(item, 'height'),
        weight: extract_weight(item, 'item_package_weight'),
        images: extract_images(item),
        bullet_points: extract_bullet_points(item),
        description: extract_attribute(item, 'product_description'),
        location: 'us',
        parent_asin: extract_parent_asin(item),
        child_asins: extract_child_asins(item),
        product_updated_at: Time.now
      }
    end

    def extract_attribute(item, attribute)
      item.dig('attributes', attribute)&.first&.dig('value')
    end

    def extract_dimension(item, dimension)
      unit = item.dig('attributes', 'item_package_dimensions')&.first&.dig(dimension, 'unit')
      value = item.dig('attributes', 'item_package_dimensions')&.first&.dig(dimension, 'value')

      # convert value to inches if in centimeters
      value = value.to_f * 0.393701 if unit == 'centimeters'

      value
    end

    def extract_weight(item, item_package_weight)
      unit = item.dig('attributes', item_package_weight)&.first&.dig('unit')
      value = item.dig('attributes', item_package_weight)&.first&.dig('value')

      conversion_factors = {
        'grams' => 0.00220462,
        'kilograms' => 2.20462,
        'ounces' => 0.0625
      }

      # convert value to pounds if in grams, kilograms or ounces
      value = value.to_f * conversion_factors[unit] if conversion_factors.key?(unit)

      value
    end

    def extract_images(item)
      item['images']&.first&.[]('images')&.map { |img| img['link'] }
    end

    def extract_bullet_points(item)
      item.dig('attributes', 'bullet_point')&.map { |bullet_point| bullet_point['value'] }
    end

    def extract_parent_asin(item)
      item['relationships']&.first&.dig('relationships')&.first&.dig('parentAsins')&.first
    end

    def extract_child_asins(item)
      item['relationships']&.first&.dig('relationships')&.first&.dig('childAsins')
    end
  end
end
