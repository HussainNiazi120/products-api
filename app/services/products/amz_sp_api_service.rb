# frozen_string_literal: true

require 'amz_sp_api'
require 'catalog-items-api-model'
require 'product-pricing-api-model'

module Products
  class AmzSpApiService < ApplicationService
    MARKET_PLACE_IDS = ['ATVPDKIKX0DER'].freeze
    REGION = 'na'
    TIME_OUT = 20
    DEBUGGING = false
    SUCCESSIVE_REQUEST_DELAY = 1 # Maximum 1 request per second
    MAX_PAGE_SIZE = 20 # Maximum 20 items per page

    def self.configure_amz_sp_api
      AmzSpApi.configure do |config|
        apply_credentials(config)
        apply_configurations(config)
        manage_tokens(config)
      end
    end

    def self.apply_credentials(config)
      config.refresh_token,
      config.client_id,
      config.client_secret,
      config.aws_access_key_id,
      config.aws_secret_access_key = amazon_sp_api_credentials
    end

    def self.apply_configurations(config)
      config.region = REGION
      config.timeout = TIME_OUT
      config.debugging = DEBUGGING
    end

    def self.manage_tokens(config)
      config.save_access_token = lambda { |access_token_key, token|
        Rails.cache.write(spapi_token_key(access_token_key), token[:access_token],
                          expires_in: token[:expires_in] - 60)
      }
      config.get_access_token = ->(access_token_key) { Rails.cache.read(spapi_token_key(access_token_key)) }
    end

    def self.amazon_sp_api_credentials
      [refresh_token, client_id, client_secret, aws_access_key_id, aws_secret_access_key]
    end

    def self.refresh_token
      Rails.application.credentials.dig(:amazon_sp_api, :refresh_token)
    end

    def self.client_id
      Rails.application.credentials.dig(:amazon_sp_api, :client_id)
    end

    def self.client_secret
      Rails.application.credentials.dig(:amazon_sp_api, :client_secret)
    end

    def self.aws_access_key_id
      Rails.application.credentials.dig(:amazon_sp_api, :aws_access_key_id) || ENV['AWS_ACCESS_KEY_ID']
    end

    def self.aws_secret_access_key
      Rails.application.credentials.dig(:amazon_sp_api, :aws_secret_access_key) || ENV['AWS_SECRET_ACCESS_KEY']
    end

    def self.spapi_token_key(access_token_key)
      "SPAPI-TOKEN-#{access_token_key}"
    end

    configure_amz_sp_api
  end
end
