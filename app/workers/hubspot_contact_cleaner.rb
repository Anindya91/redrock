class HubspotContactCleaner
  include Sidekiq::Worker
  sidekiq_options queue: 'low', retry: false

  def perform(id)
    HubspotClient.delete_contact(id)
  end
end
