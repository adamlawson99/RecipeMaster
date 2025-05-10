require "net/http"
require "uri"
require "json"

class WebRecipeFetchService
  include GeminiService

  def get_recipe_data(url)
    prompt = get_prompt url
    make_gemini_request prompt
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
