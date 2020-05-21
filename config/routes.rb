# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  get '/listings/map/:search', to: 'listings#search'
  resources :listings do
    resources :reviews
    resources :bookings, only: %i[show new create destroy] do
      resources :payments, only: [:new]
    end
  end

  get '/bookings', to: 'bookings#index'
  get '/manage', to: 'listings#manage'
  get '/payments/session', to: 'payments#get_stripe_id'
  get '/payments/success', to: 'payments#success'
  post '/payments/webhook', to: 'payments#webhook'
  root to: 'pages#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
