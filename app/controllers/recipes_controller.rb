class RecipesController < ApplicationController
  include RecipesHelper
  before_action :set_recipe, only: %i[ show edit update destroy ]

  # GET /recipes or /recipes.json
  def index
    @recipes = Recipe.all
  end

  def query
    @recipes = Recipe.all
    query_param = params[:query]
    Rails.logger.error(query_param)
    if query_param && !query_param.empty?
      elastic_search_results = ElasticSearchService.new.fetch_documents_from_index("recipes_index", query_param)
      @query_data = elastic_search_results["hits"]["hits"].map { |obj| obj["_source"] }.to_json
    else
      @query_data = Recipe.all.to_json
    end
    @tags = get_string_field_as_array(@query_data, "tags")
    @categories = get_string_field_as_array(@query_data, "categories")
    respond_to do |format|
      format.html { render "recipes/table" }
    end
  end

  # GET /recipes/1 or /recipes/1.json
  def show
  end

  # GET /recipes/new
  def new
    @recipe = Recipe.new
  end

  def new_from_web
    @recipe = Recipe.new
    @url = params[:url]
    @fetched_data = RecipeFetchService.new.fetch_recipe_data(@url)
    @fetched_data["source"] = @url
    respond_to do |format|
      format.turbo_stream { render "recipes/web_recipe" }
      format.html { render "recipes/new_from_web" }
    end
  end

  def new_from_web_form
    respond_to do |format|
      format.turbo_stream { render "recipes/web_recipe" }
      format.html { render "recipes/new_from_web" }
    end
  end

  # GET /recipes/1/edit
  def edit
    @ingredients_data = @recipe.ingredients_list
  end

  # POST /recipes or /recipes.json
  def create
    recipe_creating_service = RecipeCreatingService.new
    @recipe = RecipeCreatingService.new.create_recipe(recipe_params)
    respond_to do |format|
      if recipe_creating_service.save_recipe?(@recipe)
        format.html { redirect_to @recipe, notice: "Recipe was successfully created." }
        format.json { render :show, status: :created, location: @recipe }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recipes/1 or /recipes/1.json
  def update
    recipe_updating_service = RecipeUpdatingService.new
    respond_to do |format|
      if recipe_updating_service.update_recipe?(@recipe, recipe_params)
        format.html { redirect_to @recipe, notice: "Recipe was successfully updated." }
        format.json { render :show, status: :ok, location: @recipe }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recipes/1 or /recipes/1.json
  def destroy
    recipe_deleting_service = RecipeDeletingService.new
    recipe_deleting_service.delete_recipe?(@recipe)

    respond_to do |format|
      format.html { redirect_to recipes_path, status: :see_other, notice: "Recipe was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def get_string_field_as_array(query_data, field)
    items = JSON.parse(query_data)
    result = []
    items.each do |item|
      next if item[field].nil?
      next if item[field]&.blank?
      result += item[field].split(",")
    end
    result
  end

  def valid_json?(json)
    JSON.parse(json)
    true
  rescue JSON::ParserError, TypeError => e
    false
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_recipe
    @recipe = Recipe.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def recipe_params
    # Get the base recipe params
    recipe_parameters = params.require(:recipe).permit(
      :title,
      :source,
      :description,
      :short_description,
      :servings,
      :instructions,
      :calories,
      :macros,
      :categories,
      :tags
    )

    # Add ingredients as JSON
    recipe_parameters[:ingredients] = params[:ingredients].to_json if params[:ingredients].present?

    recipe_parameters
  end
end
