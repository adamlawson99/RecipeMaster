class RecipeCreatingService < BaseRecipeService
  def initialize
    super
  end

  def create_recipe(recipe_params)
    Recipe.new(recipe_params)
  end

  def save_recipe?(recipe)
    ActiveRecord::Base.transaction do
      raise ActiveRecord::Rollback unless recipe.save
      raise ActiveRecord::Rollback unless @elastic_search_service.save_document(RECIPES_INDEX, recipe.id, recipe.to_json)
      true
    end
  end
end
