class Recipe < ApplicationRecord
  validates :title, :short_description, presence: true, length: { maximum: 50 }
  validates :description, presence: true, length: { maximum: 1000 }
  validates :ingredients, presence: true, IsJson: true
  validates :servings, presence: true, numericality: true
  validates :calories, :macros, IsJson: true
end
