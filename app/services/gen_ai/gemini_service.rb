require "net/http"
require "uri"
require "json"

module GeminiService
  def get_gemini_request_url
    gemini_base_url = "https://generativelanguage.googleapis.com/v1beta/models/"
    gemini_model = "gemini-2.0-flash"
    gemini_api_key = Rails.application.credentials[:gen_ai_api_key]
    "#{gemini_base_url}#{gemini_model}:generateContent?key=#{gemini_api_key}"
  end

  def make_gemini_request(prompt)
    require "net/http"
    uri = URI(get_gemini_request_url).freeze
    headers = { 'Content-Type': "application/json" }
    request_body = {
      "contents": [
        {
          "parts": [
            {
              "text": prompt
            }
          ]
        }
      ]
    }.to_json

    begin
      response = Net::HTTP.post(uri, request_body, headers)

      # Parse the response and extract the data you need
      # This will depend on what data you're fetching and its format
      # For example, if it's JSON:
      recipe_data = {}
      if response.is_a?(Net::HTTPSuccess)
        response_body_json = JSON.parse(response.body)
        sanitized_body = sanitize_text(response_body_json["candidates"][0]["content"]["parts"][0]["text"])
        recipe_data = JSON.parse(sanitized_body)
      end
      recipe_data
    rescue Exception => e
      Rails.logger.error(e)
      nil
    end
  end

  def sanitize_text(text)
    text unless text.start_with?("```JSON")
    text[7..text.length - 4]
  end
end
