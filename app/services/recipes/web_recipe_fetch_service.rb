# app/services/fetch_service.rb
class WebRecipeFetchService
  def self.fetch_recipe_data(url)
    require "net/http"
    response = Net::HTTP.get_response(URI(url))

    # Parse the response and extract the data you need
    # This will depend on what data you're fetching and its format
    # For example, if it's JSON:
    JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
  end
end
