class Omega::Account < Omega
  attr_reader :id, :account_number, :account_customer, :open_date, :admin_status,
    :collateral, :account_remark_codes, :internal_status, :account_installment

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
      @account_installment = client.get_account_installment(@id, keep_alive: true)
    end
  end

  def customer
    account_customer.customer
  end

  def hubspot_object
    email = customer.email_address
    primary_address = customer.addresses.find { |p| p.primary }
    data = {
      "firstname" => customer.first_name,
      "lastname" => customer.last_name,
      "account" => account_number,
      "admin_status" => admin_status,
      "data1_primary_address_line_1" => primary_address.addr_line1,
      "data1_primary_address_line_2" => primary_address.addr_line2,
      "data1_primary_address_line_3" => primary_address.addr_line3,
      "data1_primary_address_city" => primary_address.city,
      "data1_primary_address_state" => primary_address.province.abbreviation,
      "data1_primary_address_zip_code" => primary_address.zip_code,
      "open_date" => open_date,
      "internal_status" => ["", "", "", "Active", "Closed", "Charged Off"][internal_status],
    }

    if customer.birthday.present?
      data["birthdate"] = customer.birthday
    end

    if customer.phone_numbers.present?
      primary_phone_number = customer.phone_numbers.find { |phn| phn.primary }
      data["phone_number"] = primary_phone_number.phone_number if primary_phone_number.present?
    end

    if account_installment.present?
      data.merge!({
        "next_due" => account_installment.next_due_date,
        "whole_payments_made" => account_installment.number_of_whole_payments,
        "total_balance" => account_installment.total_current_balance.to_f
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

  def neo_verify_object
    data = {
      app_id: id,
      type: "Normal",
      car_lot: "ER",
      applicant: {
        first_name: customer.first_name,
        middle_name: customer.middle_name,
        last_name: customer.last_name,
        date_of_birth: customer.birthday.strftime("%Y-%m-%d"),
        gender: [nil, "Male", "Female"][customer.sex],
        marital_status: [nil, "Single", "Married", "Domestic Partnership",
          "Other", "unknown", "Separated"][customer.marital_status] || "unknown",
        dependents_number: customer.number_of_dependents,
        time_in_area: "",
        residence_changes_3_years: "",
        previous_customer: "",
        insurance: "None",
        beacon_score: 482,
        repossessions: 1,
        chapter_13: 0,
        landline_phone: "false",
      }
    }

    residences = []
    customer.addresses.each do |address|
      residence_object = {
        street: address.addr_line1,
        city: address.city,
        state: address.state,
        zip: address.zip_code,
        residence_type: ["Physical", "Mailing"][address.address_type],
        current: "#{address.primary == true}"
      }

      if address.primary
        residence_object[:start_date] = customer.primary_address_as_of_date.strftime("%Y-%m-%d")
        residence_object[:end_date] = ""
      end

      residences << residence_object
    end

    data[:residences] = residences
  end
end
