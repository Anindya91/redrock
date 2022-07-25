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
      data["phone"] = primary_phone_number.phone_number if primary_phone_number.present?
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
      applicant: {
        first_name: customer.first_name,
        middle_name: customer.middle_name,
        last_name: customer.last_name,
        date_of_birth: customer.birthday.strftime("%Y-%m-%d"),
        gender: [nil, "Male", "Female"][customer.sex],
        marital_status: [nil, "Single", "Married", "Domestic Partnership",
          "Other", "unknown", "Separated"][customer.marital_status] || "unknown",
        dependents_number: customer.number_of_dependents,
      }
    }

    residences = []
    customer.addresses.each do |address|
      if address.primary
        residence_object = {
          street: address.addr_line1,
          city: address.city,
          state: address.province.name,
          zip: address.zip_code,
          residence_type: ["Physical", "Mailing"][address.address_type],
          current: "#{address.primary == true}"
        }

        residence_object[:start_date] = customer.primary_address_as_of_date.strftime("%Y-%m-%d")
        residence_object[:end_date] = ""

        residences << residence_object
      end
    end

    data[:residences] = residences

    deal = {}
    collateral_vehicle = collateral.collateral_vehicle
    if collateral_vehicle.present?
      deal[:car] = {
        make: collateral_vehicle.make,
        model: collateral_vehicle.model,
        year: collateral_vehicle.year,
        mileage: collateral_vehicle.mileage,
      }
    end
    if account_installment.present?
      deal[:downpayment] = account_installment.down_payment_amount
      deal[:interest_rate] = account_installment.current_rate * 100
      deal[:monthly_payment] = account_installment.regular_payment_amount
      deal[:cash_in_deal] = account_installment.cash_price
      deal[:acv] = account_installment.contractual_amount_financed / account_installment.contractual_actual_term.to_f
    end
    data[:deal] = deal if deal.present?

    employments = []
    if customer.customer_employers.present?
      customer.customer_employers.each_with_index do |employer, index|
        data_object = {
          employer: employer.employer_name,
          end_date: employer.end_date.present? ? employer.end_date.strftime("%Y-%m-%d") : "",
          start_date: employer.start_date.strftime("%Y-%m-%d"),
          monthly_net_income: employer.salary,
          pay_period: [nil, nil, nil, nil, nil, "WK"][employer.salary_frequency],
          current: (index == 0).to_s
        }
        employments << data_object
      end
    end
    data[:employments] = employments

    return data
  end
end
