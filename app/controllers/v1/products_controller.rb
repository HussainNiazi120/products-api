# frozen_string_literal: true

module V1
  class ProductsController < ApplicationController
    rescue_from Products::SearchService::MissingKeywords, with: :missing_keywords
    rescue_from Products::VariationsService::MissingAsin, with: :missing_asin
    rescue_from Products::VariationsService::ProductNotFound, with: :product_not_found
    rescue_from Products::VariationsService::VariationsNotLoaded, with: :variations_not_loaded

    def index
      products = Products::SearchService.call(search_params[:keywords])
      render json: products
    end

    def show
      product = Products::ShowService.call(params.require(:asin))
      render json: product
    end

    def variations
      variations = Products::VariationsService.call(params.require(:asin))
      render json: variations
    end

    private

    def search_params
      params.permit(:keywords)
    end

    def missing_keywords
      render json: { error: 'Missing keywords' }, status: :bad_request
    end

    def missing_asin
      render json: { error: 'Missing ASIN' }, status: :bad_request
    end

    def product_not_found
      render json: { error: "Product with asin: #{params.require(:asin)} not found" }, status: :not_found
    end

    def variations_not_loaded
      render json: { message: 'Processing request. Check back in a few seconds' }, status: :accepted
    end
  end
end
