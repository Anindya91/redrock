class ContactSyncer
  include Sidekiq::Worker

  def perform
    active_accounts = OmegaClient.new.get_active_accounts

    active_accounts.each do |account|
      email, data = account.hubspot_object
      HubspotContactWorker.perform_async(email, data)
    end
  end
end
