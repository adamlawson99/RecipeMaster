class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[ show edit update destroy ]

  # GET /recipes or /recipes.json
  def index
    @recipes = Recipe.all
  end

  def query
    @recipes = Recipe.all
    @tags = get_tags
    @categories = get_categories
    query_param = params[:query]
    Rails.logger.error(query_param)
    if query_param && !query_param.empty?
      elastic_search_results = ElasticSearchService.new.fetch_documents_from_index("recipes_index", query_param)
      @query_data = elastic_search_results["hits"]["hits"].map { |obj| obj["_source"] }.to_json
    else
      @query_data = Recipe.all.to_json
    end
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
    @recipe = Recipe.new(recipe_params)
    process_ingredients
    respond_to do |format|
      if @recipe.save
        format.html { redirect_to @recipe, notice: "Recipe was successfully created." }
        format.json { render :show, status: :created, location: @recipe }
      else
        @recipe.errors.each do |error|
          Rails.logger.error("ERRORS: #{error.full_message}")
        end
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recipes/1 or /recipes/1.json
  def update
    process_ingredients
    respond_to do |format|
      if @recipe.update(recipe_params)
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
    @recipe.destroy!

    respond_to do |format|
      format.html { redirect_to recipes_path, status: :see_other, notice: "Recipe was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def get_tags
    tags = []
    @recipes.each do |recipe|
      next if recipe.tags&.blank?
      tags += recipe.tags.split(",")
    end
    @tags = tags
  end

  def get_categories
    categories = []
    @recipes.each do |recipe|
      next if recipe.categories&.blank?
      categories += recipe.categories.split(",")
    end
    @categories = categories
  end

  def process_ingredients
    ingredients_params = params[:ingredients] || []

    # Filter out empty ingredient rows
    ingredients_data = ingredients_params.select do |ing|
      ing[:ingredient].present?
    end.map do |ing|
      {
        ingredient: ing[:ingredient],
        quantity: ing[:quantity].to_f,
        measurement: ing[:measurement]
      }
    end

    # Set the json data
    @recipe.ingredients = { ingredients: ingredients_data }.to_json
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
    params.expect(recipe: [ :title, :description, :short_description, :categories, :tags, :servings, :ingredients, :instructions, :calories, :macros, :source ])
  end
end
