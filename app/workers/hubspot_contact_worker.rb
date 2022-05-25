class HubspotContactWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'low', retry: false

  def perform(email, data)
    HubspotClient.update_contact(email, data)
  end
end
