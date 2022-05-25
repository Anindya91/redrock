Rails.application.routes.draw do
  # root "/"

  # Sidekiq
  mount Sidekiq::Web, :at => '/'
end
