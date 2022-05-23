require "sidekiq"
require "sidekiq/web"
require "sidekiq/cron/web"

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [ENV["ADMIN_USERNAME"], ENV["ADMIN_PASSWORD"]]
end

Sidekiq.configure_server do |config|
  config.redis = { :url => Rails.env.development? ? "redis://localhost:6379/0" : ENV["REDIS_URL"] }

  schedule_file = "config/schedule.yml"
  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { :url => Rails.env.development? ? "redis://localhost:6379/0" : ENV["REDIS_URL"] }
end
