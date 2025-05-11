class BaseRecipeService
  include RecipesHelper
  RECIPES_INDEX = "recipes_index".freeze
  def initialize
    @elastic_search_service = ElasticSearchService.new
  end
end
