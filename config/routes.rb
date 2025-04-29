Rails.application.routes.draw do
  root "home#index"

  get "recipe_processor/new"
  post "/recipes/new_from_web", as: :fetch_url
  get "/recipes/new_from_web",  to: "recipes#new_from_web", as: "new_recipe_from_web"
  get "/recipes/create_recipe",  to: "recipes#create_recipe", as: "create_recipe"

  resources :recipes

  get "up" => "rails/health#show", as: :rails_health_check
end
