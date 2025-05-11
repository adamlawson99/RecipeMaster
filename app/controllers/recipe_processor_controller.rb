class RecipeProcessorController < ApplicationController
  def fetch
    @url = params[:url]
    # @fetched_data = WebRecipeFetchService.fetch_recipe_data(@url)
    @fetched_data = { "title": "Chicken Burrito Bowl with Cilantro Lime Rice", "description": "This easy Chicken Burrito Bowl recipe features juicy seasoned chicken, fluffy cilantro lime rice, your favorite toppings, and a flavorful homemade burrito bowl sauce. It’s a simple healthy meal that’s perfect for meal prep, weeknight dinners, or a quick lunch!", "short_description": "Easy and healthy chicken burrito bowl recipe.", "categories": [ "Main Course", "Dinner", "Lunch", "Healthy" ], "tags": [ "chicken", "rice", "burrito bowl", "cilantro lime" ], "servings": 4, "instructions": "1. In a medium bowl, combine the chili powder, cumin, garlic powder, onion powder, salt and pepper. Set aside. \n2. Cut the chicken into 1-inch cubes and place in a bowl. Drizzle with the olive oil and toss to coat. Sprinkle the seasoning mixture over the chicken and toss to coat evenly.\n3. Heat a large skillet over medium-high heat. Add the chicken and cook until it is cooked through, about 5-7 minutes.\n4. While the chicken is cooking, prepare the cilantro lime rice. In a large bowl, combine the cooked rice, lime juice, and cilantro. Stir to combine.\n5. In a small bowl, combine the Greek yogurt, lime juice, water, and hot sauce. Stir to combine.\n6. To assemble the bowls, divide the cilantro lime rice among 4 bowls. Top with the chicken, black beans, corn, avocado, cheese and salsa. Drizzle with the Greek yogurt sauce. Serve immediately." }
    respond_to do |format|
      format.turbo_stream { render "recipes/web_recipe" }
      format.html { render "recipes/new" }
    end
  end
end
