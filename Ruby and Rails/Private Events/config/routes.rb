Rails.application.routes.draw do
  devise_for :users

  root "events#index"

  resources :events do
    resources :event_attendances, only: [:create, :destroy]
    member do
      post :invite
      patch :toggle_privacy
    end
  end

  resources :users, only: [:show, :index]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
