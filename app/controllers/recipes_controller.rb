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
    @fetched_data = JSON.parse({ "title": "Chicken Burrito Bowl with Cilantro Lime Rice", "description": "This easy Chicken Burrito Bowl recipe features juicy seasoned chicken, fluffy cilantro lime rice, your favorite toppings, and a flavorful homemade burrito bowl sauce. It’s a simple healthy meal that’s perfect for meal prep, weeknight dinners, or a quick lunch!", "short_description": "Easy and healthy chicken burrito bowl recipe.", "categories": [ "Main Course", "Dinner", "Lunch", "Healthy" ], "tags": [ "chicken", "rice", "burrito bowl", "cilantro lime" ], "servings": 4, "ingredients": [ { "ingredient": "Boneless skinless chicken breasts", "quantity": 1.5, "measurement": "lb" }, { "ingredient": "Olive oil", "quantity": 1, "measurement": "tbsp" }, { "ingredient": "Chili powder", "quantity": 1, "measurement": "tbsp" }, { "ingredient": "Cumin", "quantity": 1, "measurement": "tsp" }, { "ingredient": "Garlic powder", "quantity": 1, "measurement": "tsp" }, { "ingredient": "Onion powder", "quantity": 1, "measurement": "tsp" }, { "ingredient": "Salt", "quantity": 0.5, "measurement": "tsp" }, { "ingredient": "Black pepper", "quantity": 0.25, "measurement": "tsp" }, { "ingredient": "Cooked rice", "quantity": 3, "measurement": "cups" }, { "ingredient": "Fresh lime juice", "quantity": 2, "measurement": "tbsp" }, { "ingredient": "Fresh cilantro", "quantity": 0.25, "measurement": "cup" }, { "ingredient": "Greek yogurt or sour cream", "quantity": 0.5, "measurement": "cup" }, { "ingredient": "Lime juice", "quantity": 1, "measurement": "tbsp" }, { "ingredient": "Water", "quantity": 2, "measurement": "tbsp" }, { "ingredient": "Hot sauce", "quantity": 1, "measurement": "tsp" }, { "ingredient": "Cooked Black Beans", "quantity": 1, "measurement": "cup" }, { "ingredient": "Corn", "quantity": 1, "measurement": "cup" }, { "ingredient": "Avocado", "quantity": 1, "measurement": "" }, { "ingredient": "Shredded cheddar cheese", "quantity": 0.5, "measurement": "cup" }, { "ingredient": "Salsa", "quantity": 0.5, "measurement": "cup" } ], "instructions": "1. In a medium bowl, combine the chili powder, cumin, garlic powder, onion powder, salt and pepper. Set aside. \n2. Cut the chicken into 1-inch cubes and place in a bowl. Drizzle with the olive oil and toss to coat. Sprinkle the seasoning mixture over the chicken and toss to coat evenly.\n3. Heat a large skillet over medium-high heat. Add the chicken and cook until it is cooked through, about 5-7 minutes.\n4. While the chicken is cooking, prepare the cilantro lime rice. In a large bowl, combine the cooked rice, lime juice, and cilantro. Stir to combine.\n5. In a small bowl, combine the Greek yogurt, lime juice, water, and hot sauce. Stir to combine.\n6. To assemble the bowls, divide the cilantro lime rice among 4 bowls. Top with the chicken, black beans, corn, avocado, cheese and salsa. Drizzle with the Greek yogurt sauce. Serve immediately." }.to_json)
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
    process_ingredients(@recipe)
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
    params.expect(recipe: [ :title, :description, :short_description, :categories, :tags, :servings, :ingredients, :instructions, :calories, :macros, :source ])
  end
end
