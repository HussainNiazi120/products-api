# frozen_string_literal: true

require 'test_helper'

module Products
  class ShowTest < ActionDispatch::IntegrationTest
    include SpApiTestHelper

    setup do
      stub_rails_credentials
    end

    def product_url(asin)
      "/v1/products/#{asin}"
    end

    test 'return product' do
      product = create(:product, is_prime: true)

      stub_show_request_for_amazon_product

      perform_enqueued_jobs do
        get product_url(product.asin)
      end

      assert_response :success

      res = response.parsed_body
      assert_equal product.asin, res['asin']
      assert_equal 7900, res['price']
      assert res['is_prime']
    end

    test 'return product when product is not prime' do
      product = create(:product, asin: 'B075DBHGT6', is_prime: false)

      stub_show_request_for_merchant_product

      perform_enqueued_jobs do
        get product_url(product.asin)
      end

      assert_response :success

      res = response.parsed_body
      assert_equal product.asin, res['asin']
      assert_equal 17_985, res['price']
      assert_not res['is_prime']
    end

    test 'Do not update product price if price_updated_at < 1 hour ago' do
      product = create(:product, price: 9900, price_updated_at: 30.minutes.ago)

      stub_show_request_for_amazon_product

      perform_enqueued_jobs do
        get product_url(product.asin)
      end

      assert_response :success

      res = response.parsed_body
      assert_equal product.asin, res['asin']
      assert_equal 9900, res['price']
      assert_not res['is_prime']
    end

    test 'Update product price if price_updated_at > 1 hour ago' do
      product = create(:product, price: 9900, price_updated_at: 2.hours.ago)

      stub_show_request_for_amazon_product

      perform_enqueued_jobs do
        get product_url(product.asin)
      end

      assert_response :success

      res = response.parsed_body
      assert_equal product.asin, res['asin']
      assert_equal 7900, res['price']
      assert res['is_prime']
    end
  end
end
