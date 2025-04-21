json.extract! recipe, :id, :title, :description, :short_description, :categories, :tags, :servings, :ingredients, :instructions, :calories, :macros, :created_at, :updated_at
json.url recipe_url(recipe, format: :json)
