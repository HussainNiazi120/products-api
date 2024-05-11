# frozen_string_literal: true

class GetChildProductsJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false

  def perform(child_asins)
    child_asins.each_slice(Products::AmzSpApiService::MAX_PAGE_SIZE).with_index do |slice, index|
      Products::SearchService.call(slice, child_asins)
      unless index == child_asins.length / Products::AmzSpApiService::MAX_PAGE_SIZE
        sleep Products::AmzSpApiService::SUCCESSIVE_REQUEST_DELAY
      end
    end
  end
end
