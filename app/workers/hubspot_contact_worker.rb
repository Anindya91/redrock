class HubspotContactWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'low'

  def perform(id, email, data)
    account_object = OmegaClient.new.get_account(id)
    email, data = account_object.hubspot_object # Fetch it again from the DB for the latest data.

    HubspotClient.update_contact(email, data)
  end
end
