# frozen_string_literal: true

Rails.application.routes.draw do
  root 'listings#new'
  resources :listings, only: %i[show create]
end
