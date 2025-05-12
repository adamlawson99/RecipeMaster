class RecipeUpdatingService < BaseRecipeService
  def initialize
    super
  end
  def update_recipe?(recipe, recipe_params)
    ActiveRecord::Base.transaction do
      raise ActiveRecord::Rollback unless recipe.update(recipe_params)
      raise ActiveRecord::Rollback unless @elastic_search_service.update_document(RECIPES_INDEX, recipe.id, recipe.to_json)
      true
    end
  end
end
