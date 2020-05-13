Rails.application.routes.draw do
  devise_for :users
  resources :listings do
    resources :bookings, only: [ :new, :create, :destroy]
  end
  get '/bookings', to: 'bookings#index'
  get '/manage', to: 'listings#manage'
  root to: "pages#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

