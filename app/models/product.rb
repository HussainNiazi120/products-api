# frozen_string_literal: true

class Product < ApplicationRecord
  validates :asin, presence: true, uniqueness: true
end
