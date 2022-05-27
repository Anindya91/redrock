class ContactSyncer
  include Sidekiq::Worker

  def perform
    response = OmegaClient.new.list_accounts
    map = response[:map]
    accounts = response[:accounts]

    accounts.each do |account|
      account_object = OmegaClient.new(map).get_account(account["Id"])
      email, data = account_object.hubspot_object

      HubspotContactWorker.perform_async(email, data)
    end
  end
end
