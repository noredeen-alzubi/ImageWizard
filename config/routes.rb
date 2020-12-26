Rails.application.routes.draw do
  root to: 'pages#home'
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  concern :paginatable do
    get '(page/:page)', action: :index, on: :collection, as: ''
  end

  resources :images, except: %i[edit update], concerns: :paginatable
  post '/presigned_urls', to: 'images#get_presigned_urls'
  get '/bulk/new', to: 'images#bulk_new'
  post '/bulk/single', to: 'images#bulk_create'
  get '/me/images', to: 'images#my_index'

  direct :rails_public_blob do |blob|
    # Preserve the behaviour of `rails_blob_url` inside these environments
    # where S3 or the CDN might not be configured
    if Rails.env.development? || Rails.env.test?
      route = 
        if blob.is_a?(ActiveStorage::Variant)
          :rails_representation
        else
         :rails_blob
        end
      route_for(route, blob)
    else
      # Use an environment variable instead of hard-coding the CDN host
      File.join(ENV["CDN_HOST"], (blob.is_a?(String) ? blob.match(%r{(?<=com/).*}).to_s : blob.key))
    end
  end
end

# psutrxw0v0sb10