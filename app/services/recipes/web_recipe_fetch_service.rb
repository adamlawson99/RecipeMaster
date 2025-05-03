require "net/http"
require "uri"
require "json"

class WebRecipeFetchService
  include GeminiService

  def get_recipe_data(url)
    # prompt = get_prompt url
    # make_gemini_request prompt
    { "title": "Chicken Burrito Bowl with Cilantro Lime Rice", "description": "This easy Chicken Burrito Bowl recipe features juicy seasoned chicken, fluffy cilantro lime rice, your favorite toppings, and a flavorful homemade burrito bowl sauce. It’s a simple healthy meal that’s perfect for meal prep, weeknight dinners, or a quick lunch!", "short_description": "Easy and healthy chicken burrito bowl recipe.", "categories": [ "Main Course", "Dinner", "Lunch", "Healthy" ], "tags": [ "chicken", "rice", "burrito bowl", "cilantro lime" ], "servings": 4, "ingredients": [ { "ingredient": "Boneless skinless chicken breasts", "quantity": 1.5, "measurement": "lb" }, { "ingredient": "Olive oil", "quantity": 1, "measurement": "tbsp" }, { "ingredient": "Chili powder", "quantity": 1, "measurement": "tbsp" }, { "ingredient": "Cumin", "quantity": 1, "measurement": "tsp" }, { "ingredient": "Garlic powder", "quantity": 1, "measurement": "tsp" }, { "ingredient": "Onion powder", "quantity": 1, "measurement": "tsp" }, { "ingredient": "Salt", "quantity": 0.5, "measurement": "tsp" }, { "ingredient": "Black pepper", "quantity": 0.25, "measurement": "tsp" }, { "ingredient": "Cooked rice", "quantity": 3, "measurement": "cups" }, { "ingredient": "Fresh lime juice", "quantity": 2, "measurement": "tbsp" }, { "ingredient": "Fresh cilantro", "quantity": 0.25, "measurement": "cup" }, { "ingredient": "Greek yogurt or sour cream", "quantity": 0.5, "measurement": "cup" }, { "ingredient": "Lime juice", "quantity": 1, "measurement": "tbsp" }, { "ingredient": "Water", "quantity": 2, "measurement": "tbsp" }, { "ingredient": "Hot sauce", "quantity": 1, "measurement": "tsp" }, { "ingredient": "Cooked Black Beans", "quantity": 1, "measurement": "cup" }, { "ingredient": "Corn", "quantity": 1, "measurement": "cup" }, { "ingredient": "Avocado", "quantity": 1, "measurement": "" }, { "ingredient": "Shredded cheddar cheese", "quantity": 0.5, "measurement": "cup" }, { "ingredient": "Salsa", "quantity": 0.5, "measurement": "cup" } ], "instructions": "1. In a medium bowl, combine the chili powder, cumin, garlic powder, onion powder, salt and pepper. Set aside. \n2. Cut the chicken into 1-inch cubes and place in a bowl. Drizzle with the olive oil and toss to coat. Sprinkle the seasoning mixture over the chicken and toss to coat evenly.\n3. Heat a large skillet over medium-high heat. Add the chicken and cook until it is cooked through, about 5-7 minutes.\n4. While the chicken is cooking, prepare the cilantro lime rice. In a large bowl, combine the cooked rice, lime juice, and cilantro. Stir to combine.\n5. In a small bowl, combine the Greek yogurt, lime juice, water, and hot sauce. Stir to combine.\n6. To assemble the bowls, divide the cilantro lime rice among 4 bowls. Top with the chicken, black beans, corn, avocado, cheese and salsa. Drizzle with the Greek yogurt sauce. Serve immediately." }
  end

  private

  def get_prompt(url)
    <<~HEREDOC
      Can you examine the following website #{url} and extract information about the recipe on the page. I would the information returned as a JSON object matching the structure below:

      {
      \t"title": string (the title of the recipe),
      \t"description": string (the description of the recipe),
      \t"short_description": string (a short description of the recipe, limited to a few words or a sentence),
      \t"categories": string[] (2-4 potential categories for the recipe, such as breakfast, high protein, plant based)
      \t"tags": string[] (2-4 potential tags for the recipe, such as beef, pasta, italian),
      \t"servings": number (how many servings the recipe makes),
      \t"ingredients": [
      \t\t{
      \t\t\t"ingredient": string,
      \t\t\t"quantity": number as a decimal,
      \t\t\t"measurement": string (ex: tbsp, cup, lb)
      \t\t}
      \t],
      \t"instructions": string,
      }

      Your response should be the JSON only, nothing else. If you cannot fill out a field in the JSON please leave it blank.
      Please exclude any extra formatting such as markdown or any additional text, only return the raw json as text.
    HEREDOC
  end
end
