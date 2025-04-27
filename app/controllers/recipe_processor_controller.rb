class RecipeProcessorController < ApplicationController
  def new
    # Initial page with URL form
  end

  def fetch
    @url = params[:url]
    @fetched_data = WebRecipeFetchService.fetch_recipe_data(@url)
    respond_to do |format|
      format.turbo_stream { render "recipes/web_recipe" }
      format.html { render "recipes/new" }
    end
  end
end
