class ContactSyncer
  include Sidekiq::Worker

  def perform
    accounts = OmegaClient.new.get_accounts

    accounts.each do |account|
      email, data = account.hubspot_object
      valid_emails << email

      HubspotContactWorker.perform_async(email, data)
    end
  end
end
