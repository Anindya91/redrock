class Omega::Account < Omega
  attr_reader :id, :account_number, :account_customer, :admin_status

  def initialize(params, client)
    @id = params[:id]
    @account_number = params[:account_number]
    @admin_status = params[:map][:admin_status][params[:admin_status_id]]
    if @id.present?
      @account_customer = client.get_account_customer(@id, keep_alive: true)
    end
  end
end
