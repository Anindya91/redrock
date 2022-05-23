Rails.application.routes.draw do
  root "imports#index"
  resources :imports

  # Sidekiq
  mount Sidekiq::Web, :at => '/sidekiq'
end
