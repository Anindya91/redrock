class Omega::AccountCustomer < Omega
  attr_reader :customer

  def initialize(params, client)
    if params[:customer_id].present?
      @customer = client.get_customer(params[:customer_id], keep_alive: true)
    end
  end
end
