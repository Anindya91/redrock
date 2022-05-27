class ContactSyncer
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    response = OmegaClient.new.list_accounts
    map = response[:map]
    accounts = response[:accounts]

    accounts.each do |account|
      account_id = account["Id"]

      begin
        account_object = OmegaClient.new(map).get_account(account_id)
        email, data = account_object.hubspot_object

        HubspotClient.update_contact(email, data)
      rescue Net::ReadTimeout => e
        HubspotContactWorker.perform_async(account_id, email, data)
      end
    end
  end
end
