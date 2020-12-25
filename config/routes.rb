Rails.application.routes.draw do
  root to: 'pages#home'
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  resources :images, except: %i[edit update]
  post '/presigned_urls', to: 'images#get_presigned_urls'
  get '/bulk/new', to: 'images#bulk_new'
  post '/bulk/single', to: 'images#bulk_create'
  get '/me/images', to: 'images#my_index'
end
