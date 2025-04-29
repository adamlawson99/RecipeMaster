require "net/http"
require "uri"
require "json"

class WebRecipeFetchService
  def self.get_gemini_request_url
    gemini_base_url = "https://generativelanguage.googleapis.com/v1beta/models/"
    gemini_model = "gemini-2.0-flash"
    gemini_api_key = Rails.application.credentials[:gen_ai_api_key]
    Rails.logger.error("KEY IS #{gemini_api_key} creds: #{Rails.application.credentials[:gemini_api_key]}")
    "#{gemini_base_url}#{gemini_model}:generateContent?key=#{gemini_api_key}"
  end

  def self.get_prompt(url)
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
      \t\t\t"quantity": number,
      \t\t\t"measurement": string (ex: tbsp, cup, lb)
      \t\t}
      \t],
      \t"instructions": string,
      }

      Your response should be the JSON only, nothing else. If you cannot fill out a field in the JSON please leave it blank.#{' '}
      Please exclude any extra formatting such as markdown or any additional text, only return the raw json as text.
    HEREDOC
  end

  def self.fetch_recipe_data(url)
    require "net/http"
    uri = URI(get_gemini_request_url).freeze
    headers = { 'Content-Type': "application/json" }
    request_body = {
      "contents": [
        {
          "parts": [
            {
              "text": get_prompt(url)
            }
          ]
        }
      ]
    }.to_json

    Rails.logger.error("REQUEST URL: #{uri}")
    Rails.logger.error("REQUEST BODY: #{request_body}")

    begin
      response = Net::HTTP.post(uri, request_body, headers)
      Rails.logger.error("RESPONSE => Success: response.code, body: #{response.body}")

      # Parse the response and extract the data you need
      # This will depend on what data you're fetching and its format
      # For example, if it's JSON:
      body = {}
      if response.is_a?(Net::HTTPSuccess)
        body = JSON.parse(response.body)
        Rails.logger.error("BODY: #{body["candidates"][0]["content"]["parts"][0]["text"]}")
        sanitized_body = sanitize_text(body["candidates"][0]["content"]["parts"][0]["text"])
        Rails.logger.error("SANITIZED BODY: #{sanitized_body}")
        body = JSON.parse(sanitized_body)
      end
      body
    rescue Exception => e
      Rails.logger.error(e)
      nil
    end
  end

  def self.sanitize_text(text)
    text unless text.start_with?("```JSON")
    text[7..text.length - 4]
  end
end
