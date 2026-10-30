Rails.application.routes.draw do
  # Default root route to kittens#index as required
  root "kittens#index"

  # All 7 RESTful actions for kittens
  resources :kittens

  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check
end
