require "net/http"
require "uri"
require "json"

class RecipeFetchService
  def initialize
    @web_recipe_fetch_service = WebRecipeFetchService.new
    @tiktok_recipe_fetch_service = TiktokRecipeFetchService.new
  end

  def fetch_recipe_data(url)
    if url.include? "tiktok.com"
      @tiktok_recipe_fetch_service.get_recipe_data url
    else
      @web_recipe_fetch_service.get_recipe_data url
    end
  end
end
