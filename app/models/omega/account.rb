class Omega::Account < Omega
  attr_reader :id, :account_number, :account_customer, :admin_status, :collateral

  def initialize(params, client)
    @id = params[:id]
    @account_number = params[:account_number]
    @admin_status = params[:map][:admin_status][params[:admin_status_id]]
    if @id.present?
      @account_customer = client.get_account_customer(@id, keep_alive: true)
      @collateral = client.get_collateral(@id, keep_alive: true)
    end
  end

  def hubspot_object
    email = account_customer.customer.email_address
    primary_address = account_customer.customer.addresses.find { |p| p.primary }
    data = {
      "firstname" => account_customer.customer.first_name,
      "lastname" => account_customer.customer.last_name,
      "account" => account_number,
      "admin_status" => admin_status,
      "birthdate" => account_customer.customer.birthday,
      "data1_primary_address_line_1" => primary_address.addr_line1,
      "data1_primary_address_line_2" => primary_address.addr_line2,
      "data1_primary_address_line_3" => primary_address.addr_line3,
      "data1_primary_address_city" => primary_address.city,
      "data1_primary_address_state" => primary_address.province.abbreviation,
      "data1_primary_address_zip_code" => primary_address.zip_code,
    }

    return [email, data]
  end
end
