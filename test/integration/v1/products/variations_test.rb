# frozen_string_literal: true

require 'test_helper'

module Products
  class VariationsTest < ActionDispatch::IntegrationTest
    include SpApiTestHelper

    setup do
      stub_rails_credentials
      @asin = 'B0CMT86BZ7'
      @parent_asin = 'B0CMYK2MFZ'
    end

    def variations_url(asin)
      "/v1/products/#{asin}/variations"
    end

    def perform_request(asin)
      Products::AmzSpApiService.stub_const(:SUCCESSIVE_REQUEST_DELAY, 0) do
        perform_enqueued_jobs do
          get variations_url(asin)
        end
      end
    end

    test 'API returns and saves variations to database' do
      product = create(:product, asin: @asin, parent_asin: @parent_asin)

      stub_parent_product_request
      stub_child_products_request1
      stub_child_products_request2

      perform_request(@asin)

      assert_response :success

      product.reload
      assert_equal 30, product.variation_asins.size
      assert_equal 30, Product.where(parent_asin: product.parent_asin).size
      assert_equal 30, response.parsed_body.count
    end

    test 'database returns variations when they exist' do
      Products::SearchService.expects(:call).never

      parent_product = create(:product,
                              asin: @parent_asin,
                              child_asins: %w[B0CMT86BZ7 B0CMT86BZ8 B0CMT86BZ9],
                              product_updated_at: 1.day.ago)
      first_child = create(:product,
                           asin: @asin,
                           parent_asin: @parent_asin,
                           variation_asins: %w[B0CMT86BZ7 B0CMT86BZ8 B0CMT86BZ9],
                           product_updated_at: 1.day.ago)
      create(:product, asin: 'B0CMT86BZ8', parent_asin: @parent_asin,
                       variation_asins: %w[B0CMT86BZ7 B0CMT86BZ7 B0CMT86BZ9], product_updated_at: 1.day.ago)
      create(:product, asin: 'B0CMT86BZ9', parent_asin: @parent_asin,
                       variation_asins: %w[B0CMT86BZ7 B0CMT86BZ7 B0CMT86BZ9], product_updated_at: 1.day.ago)

      get variations_url(first_child.asin)

      assert_response :success

      assert_equal parent_product.child_asins, response.parsed_body
    end

    test 'API returns child asins when product has not been updated for over a week' do
      stub_parent_product_request
      stub_child_products_request1
      stub_child_products_request2

      parent_product = create(:product, asin: @parent_asin, child_asins: %w[B0CMT86BZ7 B0CMT86BZ8 B0CMT86BZ9])
      first_child = create(:product, asin: @asin, parent_asin: @parent_asin,
                                     variation_asins: %w[B0CMT86BZ7 B0CMT86BZ8 B0CMT86BZ9],
                                     product_updated_at: 2.weeks.ago)
      create(:product, asin: 'B0CMT611Z5', parent_asin: @parent_asin)
      create(:product, asin: 'B0CMT61M5X', parent_asin: @parent_asin)

      assert_equal 3, first_child.variation_asins.size
      assert_equal 3, Product.where(parent_asin: parent_product.asin).size

      perform_request(first_child.asin)

      assert_response :success

      first_child.reload
      assert_equal 30, first_child.variation_asins.size
      assert_equal 30, Product.where(parent_asin: parent_product.asin).size
      assert_equal 30, response.parsed_body.count
    end

    test 'return 404 when product does not exist in database' do
      stub_parent_product_request

      perform_request('XXX')

      assert_response :not_found

      res = response.parsed_body
      assert_equal 'Product with asin: XXX not found', res['error']
    end
  end
end
