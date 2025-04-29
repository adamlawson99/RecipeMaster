class Recipe < ApplicationRecord
  validates :title, :short_description, presence: true, length: { maximum: 50 }
  validates :description, presence: true, length: { maximum: 1000 }
  validates :ingredients, presence: true, IsJson: true
  validates :servings, presence: true, numericality: true
  validates :calories, :macros, IsJson: true

  def ingredients_list
    self.ingredients.present? ? JSON.parse(self.ingredients)["ingredients"] : []
  end

  # Make sure ingredients are always a valid structure
  def ingredients
    super || { "ingredients" => [] }
  end
end
