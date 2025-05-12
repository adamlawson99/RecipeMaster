module RecipesHelper
  def process_ingredients(recipe, recipe_params)
    Rails.logger.error("RECIPE: #{recipe.to_json}")
    Rails.logger.error("recipe_params: #{recipe_params.to_json}")
    Rails.logger.error("ingredients_params: #{recipe_params[:ingredients]}")
    ingredients_params = recipe_params[:ingredients] || []

    # Filter out empty ingredient rows
    ingredients_data = ingredients_params.select do |ingredient|
      ingredient[:ingredient].present?
    end.map do |ingredient|
      {
        ingredient: ingredient[:ingredient],
        quantity: ingredient[:quantity].to_f,
        measurement: ingredient[:measurement]
      }
    end

    # Set the json data
    recipe.ingredients = { ingredients: ingredients_data }.to_json
  end
end
