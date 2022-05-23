Rails.application.routes.draw do
  root "imports#index"

  # Sidekiq
  mount Sidekiq::Web, :at => '/sidekiq'
end
