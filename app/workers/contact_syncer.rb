class ContactSyncer
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    accounts = OmegaClient.new.list_accounts

    accounts.each do |account|
      begin
        email, data = account.hubspot_object

        HubspotClient.update_contact(email, data)
      rescue Net::ReadTimeout => e
        HubspotContactWorker.perform_async(account.id, email, data)
      end
    end
  end
end
