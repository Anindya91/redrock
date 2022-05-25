class ContactSyncer
  include Sidekiq::Worker

  def perform
    active_accounts = OmegaClient.new.get_active_accounts

    valid_emails = []
    active_accounts.each do |account|
      email, data = account.hubspot_object
      valid_emails << email

      HubspotContactWorker.perform_async(email, data)
    end

    all_contacts = HubspotClient.list_contacts
    all_contacts.each do |c|
      if !valid_emails.include?(c["properties"]["email"])
        # HubspotContactCleaner.perform_async(c["id"])
      end
    end
  end
end
