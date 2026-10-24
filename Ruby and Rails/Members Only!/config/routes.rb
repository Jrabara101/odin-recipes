Rails.application.routes.draw do
  devise_for :users

  resources :posts, only: [:new, :create, :index]

  root "posts#index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
