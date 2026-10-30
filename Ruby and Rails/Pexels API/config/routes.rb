# frozen_string_literal: true

Rails.application.routes.draw do
  # Reveal health status on /up
  get "up" => "rails/health#show", as: :rails_health_check

  # Root path to static_pages#home
  root "static_pages#home"
  get "home", to: "static_pages#home"
end
