Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  #get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # Route for user registration
  post '/register', to: 'users#create'

  # Route for token generation (login)
  post '/login', to: 'authentication#create'

  # Routes for blob operations
  # Define the POST request for blob creation
  post '/v1/blobs', to: 'blobs#create'

  # Define the GET request for retrieving a blob by ID
  get '/v1/blobs/:id', to: 'blobs#show', as: 'blob'
end
