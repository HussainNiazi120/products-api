# frozen_string_literal: true

require 'test_helper'

module Products
  class SearchTest < ActionDispatch::IntegrationTest
    include SpApiTestHelper

    setup do
      stub_rails_credentials
    end

    def search_url
      '/v1/products'
    end

    # rubocop:disable all
    def assert_product_details(product)
      assert_equal 'Apple', product['brand']
      assert_equal 'Apple iPhone 15 Plus, 128GB, Blue - Unlocked (Renewed)', product['name']
      assert_equal 7, product['length']
      assert_equal 5, product['width']
      assert_equal 4, product['height']
      assert_equal 0.7, product['weight']
      assert_equal 9, product['images'].size
      assert_equal 5, product['bullet_points'].size
      assert_equal 'The iPhone 15 Plus has a 6.7 inch all-screen Super Retina XDR display ' \
                   'with the Dynamic Island. The back is color-infused glass, and there is a ' \
                   'contoured-edge anodized aluminum band around the frame. The side button is ' \
                   'on the right side of the device. There are two cameras on the back: Ultra Wide ' \
                   'and Main. In the United States, there is no SIM tray. In other countries or ' \
                   'regions, there is a SIM tray on the left side that holds a fourth form factor ' \
                   '(4FF) nano-SIM card. On the bottom there is a USB-C connector for charging and ' \
                   'transferring data.', product['description']
      assert_nil product['price']
      assert_nil product['price_updated_at']
      assert_nil product['is_prime']
      assert_not_nil product['product_updated_at']
      assert_equal 'us', product['location']
      assert_equal 'B0CMYK2MFZ', product['parent_asin']
    end
    # rubocop:enable all

    test 'should get bad_request when no keywords provided' do
      get search_url

      assert_response :bad_request
    end

    test 'should get bad_request when empty keywords provided' do
      get search_url, params: { keywords: '' }

      assert_response :bad_request
    end

    test 'should get bad_request when keywords is nil' do
      get search_url, params: { keywords: nil }

      assert_response :bad_request
    end

    test 'return products when keywords provided' do
      search_result_file = File.read(Rails.root.join('test', 'fixtures', 'files', 'sample_search_result.json'))
      JSON.parse(search_result_file)

      stub_search_request

      perform_enqueued_jobs do
        assert_difference 'Product.count', 20 do
          get search_url, params: { keywords: 'iphone' }
        end
      end

      product = Product.find_by(asin: 'B0CMT39J9B')
      assert_product_details(product)

      assert_response :success
    end

    test 'return products regardless of update_products_job execution' do
      search_result_file = File.read(Rails.root.join('test', 'fixtures', 'files', 'sample_search_result.json'))
      JSON.parse(search_result_file)

      stub_search_request

      assert_difference 'Product.count', 0 do
        get search_url, params: { keywords: 'iphone' }
      end

      products = response.parsed_body
      assert_equal 20, products.size

      products.find { |product| product['asin'] == 'B0CMT39J9B' }

      assert_response :success
    end

    test 'Ensure all units are converted to inches and pounds' do
      search_result_file = File.read(Rails.root.join('test', 'fixtures', 'files', 'sample_search_result.json'))
      JSON.parse(search_result_file)

      stub_search_request

      perform_enqueued_jobs do
        assert_difference 'Product.count', 20 do
          get search_url, params: { keywords: 'iphone' }
        end
      end

      product_with_cm_and_kilograms = Product.find_by(asin: 'B0CNL663BM')
      assert_in_delta 3.11, product_with_cm_and_kilograms.length, 0.01
      assert_in_delta 6.81, product_with_cm_and_kilograms.width, 0.01
      assert_in_delta 10.04, product_with_cm_and_kilograms.height, 0.01
      assert_in_delta 0.78, product_with_cm_and_kilograms.weight, 0.01

      product_with_ounces = Product.find_by(asin: 'B09LPB9SQH')
      assert_in_delta 0.023, product_with_ounces.weight, 0.01

      assert_response :success
    end
  end
end
