Rails.application.routes.draw do
  root to: 'pages#home'
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  resources :images, except: %i[edit update]
  # get '/bulk/new', to: 'archives#new'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
