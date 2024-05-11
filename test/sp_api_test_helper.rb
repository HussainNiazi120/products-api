# frozen_string_literal: true

module SpApiTestHelper
  def stub_rails_credentials(&block)
    Rails.application.stubs(:credentials).returns(amazon_sp_api: { refresh_token: 'XXX',
                                                                   client_id: 'XXX',
                                                                   client_secret: 'XXX',
                                                                   aws_access_key_id: 'XXX',
                                                                   aws_secret_access_key: 'XXX' }, &block)
  end

  def stub_autohrization_request
    stub_request(:post, 'https://api.amazon.com/auth/o2/token').to_return(status: 200, body: {
      "access_token": '1234',
      "refresh_token": "'1234'",
      "token_type": 'bearer',
      "expires_in": 3600
    }.to_json, headers: {})
  end

  def stub_search_request
    search_result_file = File.read(Rails.root.join('test', 'fixtures', 'files', 'sample_search_result.json'))
    search_result_data = JSON.parse(search_result_file)

    stub_autohrization_request

    stub_request(:get, 'https://sellingpartnerapi-na.amazon.com/catalog/2022-04-01/items?includedData=attributes,images,relationships&keywords=iphone&marketplaceIds=ATVPDKIKX0DER&pageSize=20')
      .to_return(status: 200, body: search_result_data.to_json, headers: {})
  end

  def stub_show_request_for_amazon_product
    show_file = File.read(Rails.root.join('test', 'fixtures', 'files', 'sample_pricing_amazon.json'))
    show_data = JSON.parse(show_file)

    stub_autohrization_request

    stub_request(:get, 'https://sellingpartnerapi-na.amazon.com/products/pricing/v0/items/B0932QJ2JZ/offers?ItemCondition=New&MarketplaceId=ATVPDKIKX0DER')
      .to_return(status: 200, body: show_data.to_json, headers: {})
  end

  def stub_show_request_for_merchant_product
    show_file = File.read(Rails.root.join('test', 'fixtures', 'files', 'sample_pricing_merchant.json'))
    show_data = JSON.parse(show_file)

    stub_autohrization_request

    stub_request(:get, 'https://sellingpartnerapi-na.amazon.com/products/pricing/v0/items/B075DBHGT6/offers?ItemCondition=New&MarketplaceId=ATVPDKIKX0DER')
      .to_return(status: 200, body: show_data.to_json, headers: {})
  end

  def stub_parent_product_request
    show_file = File.read(Rails.root.join('test', 'fixtures', 'files', 'sample_parent_product.json'))
    show_data = JSON.parse(show_file)

    stub_autohrization_request

    stub_request(:get, 'https://sellingpartnerapi-na.amazon.com/catalog/2022-04-01/items?includedData=attributes,images,relationships&keywords=B0CMYK2MFZ&marketplaceIds=ATVPDKIKX0DER&pageSize=20')
      .to_return(status: 200, body: show_data.to_json, headers: {})
  end

  def stub_child_products_request1
    show_file = File.read(Rails.root.join('test', 'fixtures', 'files', 'sample_child_products_1.json'))
    show_data = JSON.parse(show_file)

    stub_autohrization_request

    stub_request(:get, 'https://sellingpartnerapi-na.amazon.com/catalog/2022-04-01/items?includedData=attributes,images,relationships&keywords=B0CMT86BZ7,B0CMT611Z5,B0CMT61M5X,B0CMT44L1N,B0CMSYCSTD,B0CMSY4MVZ,B0CMSZ8TSK,B0CMSVPRPC,B0CMT2RH6T,B0CMSZ7XB6,B0CMSYJGQS,B0CMT2R5CM,B0CMTB5N7Y,B0CMT4WGB8,B0CMT5ZVV2,B0CMSX9XQD,B0CMSZTP9G,B0CMSTSMFH,B0CMT44WQB,B0CMT2QMMS&marketplaceIds=ATVPDKIKX0DER&pageSize=20')
      .to_return(status: 200, body: show_data.to_json, headers: {})
  end

  def stub_child_products_request2
    show_file = File.read(Rails.root.join('test', 'fixtures', 'files', 'sample_child_products_2.json'))
    show_data = JSON.parse(show_file)

    stub_autohrization_request

    stub_request(:get, 'https://sellingpartnerapi-na.amazon.com/catalog/2022-04-01/items?includedData=attributes,images,relationships&keywords=B0CMT38L7V,B0CMSXPVPS,B0CMSZPLXD,B0CMT3DX7F,B0CMSXCB43,B0CMSZH3YK,B0CMT3MQ2Q,B0CMSY86JR,B0CMT623FS,B0CMT2QXCJ&marketplaceIds=ATVPDKIKX0DER&pageSize=20')
      .to_return(status: 200, body: show_data.to_json, headers: {})
  end
end
