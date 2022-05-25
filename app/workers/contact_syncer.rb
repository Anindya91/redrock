class ContactSyncer
  include Sidekiq::Worker

  def perform
    active_accounts = OmegaClient.new.get_active_accounts

    active_accounts.each do |account|
      email, data = account.hubspot_object
      HubspotClient.sidekiq_delay(queue: 'low').update_contact(email, data)
    end
  end
end
