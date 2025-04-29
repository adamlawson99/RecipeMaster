class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[ show edit update destroy ]

  # GET /recipes or /recipes.json
  def index
    @recipes = Recipe.all
    @tags = get_tags
    @categories = get_categories
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
    # @fetched_data = WebRecipeFetchService.fetch_recipe_data(@url)
    @fetched_data = { "title": "Chicken Burrito Bowl with Cilantro Lime Rice", "description": "This easy Chicken Burrito Bowl recipe features juicy seasoned chicken, fluffy cilantro lime rice, your favorite toppings, and a flavorful homemade burrito bowl sauce. It’s a simple healthy meal that’s perfect for meal prep, weeknight dinners, or a quick lunch!", "short_description": "Easy and healthy chicken burrito bowl recipe.", "categories": [ "Main Course", "Dinner", "Lunch", "Healthy" ], "tags": [ "chicken", "rice", "burrito bowl", "cilantro lime" ], "servings": 4, "ingredients": [ { "ingredient": "Boneless skinless chicken breasts", "quantity": 1.5, "measurement": "lb" }, { "ingredient": "Olive oil", "quantity": 1, "measurement": "tbsp" }, { "ingredient": "Chili powder", "quantity": 1, "measurement": "tbsp" }, { "ingredient": "Cumin", "quantity": 1, "measurement": "tsp" }, { "ingredient": "Garlic powder", "quantity": 1, "measurement": "tsp" }, { "ingredient": "Onion powder", "quantity": 1, "measurement": "tsp" }, { "ingredient": "Salt", "quantity": 0.5, "measurement": "tsp" }, { "ingredient": "Black pepper", "quantity": 0.25, "measurement": "tsp" }, { "ingredient": "Cooked rice", "quantity": 3, "measurement": "cups" }, { "ingredient": "Fresh lime juice", "quantity": 2, "measurement": "tbsp" }, { "ingredient": "Fresh cilantro", "quantity": 0.25, "measurement": "cup" }, { "ingredient": "Greek yogurt or sour cream", "quantity": 0.5, "measurement": "cup" }, { "ingredient": "Lime juice", "quantity": 1, "measurement": "tbsp" }, { "ingredient": "Water", "quantity": 2, "measurement": "tbsp" }, { "ingredient": "Hot sauce", "quantity": 1, "measurement": "tsp" }, { "ingredient": "Cooked Black Beans", "quantity": 1, "measurement": "cup" }, { "ingredient": "Corn", "quantity": 1, "measurement": "cup" }, { "ingredient": "Avocado", "quantity": 1, "measurement": "" }, { "ingredient": "Shredded cheddar cheese", "quantity": 0.5, "measurement": "cup" }, { "ingredient": "Salsa", "quantity": 0.5, "measurement": "cup" } ], "instructions": "1. In a medium bowl, combine the chili powder, cumin, garlic powder, onion powder, salt and pepper. Set aside. \n2. Cut the chicken into 1-inch cubes and place in a bowl. Drizzle with the olive oil and toss to coat. Sprinkle the seasoning mixture over the chicken and toss to coat evenly.\n3. Heat a large skillet over medium-high heat. Add the chicken and cook until it is cooked through, about 5-7 minutes.\n4. While the chicken is cooking, prepare the cilantro lime rice. In a large bowl, combine the cooked rice, lime juice, and cilantro. Stir to combine.\n5. In a small bowl, combine the Greek yogurt, lime juice, water, and hot sauce. Stir to combine.\n6. To assemble the bowls, divide the cilantro lime rice among 4 bowls. Top with the chicken, black beans, corn, avocado, cheese and salsa. Drizzle with the Greek yogurt sauce. Serve immediately." }
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
    Rails.logger.error "HERE1"
    @recipe = Recipe.new(recipe_params)
    Rails.logger.error "HERE2"
    process_ingredients
    respond_to do |format|
      if @recipe.save
        format.html { redirect_to @recipe, notice: "Recipe was successfully created." }
        format.json { render :show, status: :created, location: @recipe }
      else
        Rails.logger.error("ERRORS: #{@recipe.errors}")
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
    params.expect(recipe: [ :title, :description, :short_description, :categories, :tags, :servings, :ingredients, :instructions, :calories, :macros ])
  end
end
