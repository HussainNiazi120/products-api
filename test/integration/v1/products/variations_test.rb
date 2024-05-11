# frozen_string_literal: true

require 'test_helper'

module Products
  class VariationsTest < ActionDispatch::IntegrationTest
    include SpApiTestHelper

    setup do
      stub_rails_credentials
    end

    def variations_url(asin)
      "/v1/products/#{asin}/variations"
    end

    test 'returns 202 when variations have not been saved to database' do
      product = create(:product, asin: 'B0CMT86BZ7', parent_asin: 'B0CMYK2MFZ')

      stub_parent_product_request
      stub_child_products_request1
      stub_child_products_request2

      Products::AmzSpApiService.stub_const(:SUCCESSIVE_REQUEST_DELAY, 0) do
        perform_enqueued_jobs do
          get variations_url('B0CMT86BZ7')
        end
      end

      assert_response :accepted

      assert_equal 'Processing request. Check back in a few seconds', response.parsed_body['message']
      product.reload
      assert_equal 30, product.variation_asins.size
      assert_equal 30, Product.where(parent_asin: 'B0CMYK2MFZ').size
    end

    test 'returns variations when they exist in database' do
      Products::SearchService.expects(:call).never

      parent_product = create(:product, asin: 'B0CMYK2MFZ', child_asins: %w[B0CMT86BZ7 B0CMT86BZ8 B0CMT86BZ9])
      first_child = create(:product, asin: 'B0CMT86BZ7', parent_asin: 'B0CMYK2MFZ',
                                     variation_asins: %w[B0CMT86BZ7 B0CMT86BZ8 B0CMT86BZ9])
      create(:product, asin: 'B0CMT86BZ8', parent_asin: 'B0CMYK2MFZ',
                       variation_asins: %w[B0CMT86BZ7 B0CMT86BZ7 B0CMT86BZ9])
      create(:product, asin: 'B0CMT86BZ9', parent_asin: 'B0CMYK2MFZ',
                       variation_asins: %w[B0CMT86BZ7 B0CMT86BZ7 B0CMT86BZ9])

      get variations_url(first_child.asin)

      assert_response :success

      assert_equal parent_product.child_asins, response.parsed_body
    end
  end
end
