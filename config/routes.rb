Rails.application.routes.draw do
  resources :ticket_types
  devise_for :users
  resources :tickets do
    member do
      patch :take
    end
    resources :comments
  end
  resources :scopes
  resources :ticket_statuses
  resources :buildings
  resources :users, path: "admin/users" do
    collection do
      get :residents
      get :colaborators
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  authenticated :user do
    root "home#index", as: :authenticated_root
  end

  unauthenticated do
    root "home#index", as: :unauthenticated_root
  end
end
