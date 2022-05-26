class HubspotContactWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'low'

  def perform(email, data)
    HubspotClient.update_contact(email, data)
  end
end
