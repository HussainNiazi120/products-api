# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'amz_sp_api'
require 'product-pricing-api-model'
require 'sidekiq/testing'
require 'mocha/minitest'
require 'webmock/minitest'
require 'minitest/stub_const'
require 'sp_api_test_helper'

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    include FactoryBot::Syntax::Methods
  end
end
