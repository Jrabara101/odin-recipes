Rails.application.routes.draw do
  devise_for :users

  root "posts#index"

  resources :posts, only: [:index, :create, :destroy, :show] do
    resources :likes, only: [:create, :destroy]
    resources :comments, only: [:create, :destroy]
  end

  resources :users, only: [:index, :show, :edit, :update]
  resources :friendships, only: [:create, :update, :destroy]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
