class RecipeDeletingService < BaseRecipeService
  def initialize
    super
  end
  def delete_recipe?(recipe)
    ActiveRecord::Base.transaction do
      raise ActiveRecord::Rollback unless recipe.destroy!
      raise ActiveRecord::Rollback unless @elastic_search_service.delete_document(RECIPES_INDEX, recipe.id)
      true
    end
  end
end
