class Omega::Account < Omega
  attr_reader :id, :account_number, :account_customer

  def initialize(params, client)
    @id = params[:id]
    @account_number = params[:account_number]
    if @id.present?
      @account_customer = client.get_account_customer(@id, keep_alive: true)
    end
  end
end
