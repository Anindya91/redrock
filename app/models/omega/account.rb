class Omega::Account < Omega
  attr_reader :id, :account_number, :account_customer, :open_date, :admin_status,
    :collateral, :account_remark_codes, :internal_status

  def initialize(params, client)
    @id = params[:id]
    @account_number = params[:account_number]
    @open_date = params[:open_date]
    @internal_status = params[:internal_status]
    @admin_status = params[:map][:admin_status][params[:admin_status_id]]
    if @id.present?
      @account_customer = client.get_account_customer(@id, keep_alive: true)
      @collateral = client.get_collateral(@id, keep_alive: true)
      @account_remark_codes = client.get_account_remark_codes(@id, keep_alive: true)
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
      "open_date" => open_date,
    }

    int_status = [nil, nil, nil, "Active"][internal_status]
    if int_status.present?
      data.merge!({
        "internal_status" => int_status
      })
    end

    collateral_vehicle = collateral.collateral_vehicle
    if collateral_vehicle.present?
      data.merge!({
        "collateral_make" => collateral_vehicle.make,
        "collateral_model" => collateral_vehicle.model,
        "collateral_year" => collateral_vehicle.year,
        "collateral_vin" => collateral_vehicle.vin,
        "collateral_mileage" => collateral_vehicle.mileage,
      })
    end

    return [email, data]
  end
end
