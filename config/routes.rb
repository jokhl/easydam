Rails.application.routes.draw do
  root "home#index"

  get "/login", to: "user_sessions#new", as: :new_login
  post "/login", to: "user_sessions#create", as: :login

  scope :api do
    get '/basket', to: "basket#show", as: :basket
    post '/basket/add', to: "basket#add", as: :add_to_basket
    get '/basket/download', to: "basket#download", as: :download_basket
    get '/basket/clear', to: "basket#clear", as: :clear_basket
    
    resources :import_sessions, :properties, :roles, :permissions,
      :users, :search
    
    resources :assets do
      resources :tags
    end
  end

  # https://medium.com/@goncalvesjoao/rails-special-route-for-single-page-applications-de9e6bf32199
  get "*path", to: "home#index", constraints: ->(request) do
    !request.xhr? && request.format.html?
  end
end
