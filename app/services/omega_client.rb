class OmegaClient
  def initialize
    @map = {}
    @client = TinyTds::Client.new(
      username: Rails.application.credentials.omega_username,
      password: Rails.application.credentials.omega_password,
      host: Rails.application.credentials.omega_host,
      database: Rails.application.credentials.omega_database
    )
  end

  def get_active_accounts(keep_alive: false)
    status_fields = ["Id", "Code"]
    status_query = [{ key: "Code", values: ["A", "AV"] }]
    status_result = sql_execute("AdminStatus", fields: status_fields, query: status_query)

    status_map = {}
    status_result.to_a.map { |s| status_map[s["Id"]] = s["Code"] }
    @map[:admin_status] = status_map

    cache_provinces(keep_alive: true)
    cache_countries(keep_alive: true)

    fields = ["Id", "AccountNumber", "AdminStatusId", "OpenDate"]
    query = [{ key: "AdminStatusId", values: status_map.keys }]
    result = sql_execute("Account", fields: fields, query: query)
    data = symbolize_data(result.to_a, class_name: "Omega::Account")

    close_connection unless keep_alive
    return data
  end

  def get_account_customer(account_id, keep_alive: false)
    fields = ["Id", "CustomerId"]
    query = [{ key: "AccountId", values: [account_id] }]
    result = sql_execute("AccountCustomer", fields: fields, query: query)
    data = symbolize_data(result.to_a, class_name: "Omega::AccountCustomer")

    close_connection unless keep_alive
    return data.first
  end

  def get_customer(customer_id, keep_alive: false)
    fields = ["Id", "FirstName", "MiddleName", "LastName", "EmailAddress", "Birthday"]
    query = [{ key: "Id", values: [customer_id] }]
    result = sql_execute("Customer", fields: fields, query: query)
    data = symbolize_data(result.to_a, class_name: "Omega::Customer")

    close_connection unless keep_alive
    return data.first
  end

  def get_phone_numbers(customer_id, keep_alive: false)
    query = [{ key: "ParentId", values: [customer_id] }]
    result = sql_execute("PhoneNumber", query: query)
    data = symbolize_data(result.to_a, class_name: "Omega::PhoneNumber")

    close_connection unless keep_alive
    return data
  end

  def get_addresses(customer_id, keep_alive: false)
    query = [{ key: "ParentId", values: [customer_id] }, { key: "Active", values: [true] }]
    result = sql_execute("Address", query: query)
    data = symbolize_data(result.to_a, class_name: "Omega::Address")

    close_connection unless keep_alive
    return data
  end

  def get_province(province_id, keep_alive: false)
    if @map[:provinces].present?
      existing_data = @map[:provinces].select { |p| p.id == province_id }
    end

    if existing_data.present?
      data = existing_data
    else
      query = [{ key: "Id", values: [province_id] }]
      result = sql_execute("Province", query: query, schema: "Global")
      data = symbolize_data(result.to_a, class_name: "Omega::Province")
    end

    close_connection unless keep_alive
    return data.first
  end

  def get_country(country_id, keep_alive: false)
    if @map[:countries].present?
      existing_data = @map[:countries].select { |c| c.id == country_id }
    end

    if existing_data.present?
      data = existing_data
    else
      query = [{ key: "Id", values: [country_id] }]
      result = sql_execute("Country", query: query, schema: "Global")
      data = symbolize_data(result.to_a, class_name: "Omega::Country")
    end

    close_connection unless keep_alive
    return data.first
  end

  def get_collateral(account_id, keep_alive: false)
    fields = ["Id", "CollateralType"]
    query = [{ key: "AccountId", values: [account_id] }]
    result = sql_execute("Collateral", fields: fields, query: query)
    data = symbolize_data(result.to_a, class_name: "Omega::Collateral")

    close_connection unless keep_alive
    return data.first
  end

  def get_collateral_vehicle(collateral_id, keep_alive: false)
    fields = ["Id", "VIN", "Mileage", "Year", "Make", "Model"]
    query = [{ key: "CollateralId", values: [collateral_id] }]
    result = sql_execute("CollateralVehicle", fields: fields, query: query)
    data = symbolize_data(result.to_a, class_name: "Omega::CollateralVehicle")

    close_connection unless keep_alive
    return data.first
  end

  def cache_provinces(keep_alive: false)
    result = sql_execute("Province", schema: "Global")
    data = symbolize_data(result.to_a, class_name: "Omega::Province")

    @map[:provinces] = data

    close_connection unless keep_alive
    return data
  end

  def cache_countries(keep_alive: false)
    result = sql_execute("Country", schema: "Global")
    data = symbolize_data(result.to_a, class_name: "Omega::Country")

    @map[:countries] = data

    close_connection unless keep_alive
    return data
  end

  private

  def symbolize_data(data, class_name: nil)
    new_data = data.map { |d| d.deep_transform_keys { |key| key.underscore }.symbolize_keys }
    if class_name.present?
      new_data = new_data.map { |d| class_name.constantize.new(d.merge({ map: @map }), self) }
    end

    return new_data
  end

  def close_connection
    @client.close
  end

  def sql_execute(table_name, fields: ["*"], query: [], schema: "Common")
    @client.execute(sql_select_command(fields, table_name, query, schema))
  end

  def sql_select_command(fields, table_name, query, schema)
    string = "SELECT #{select_fields(fields)} FROM #{schema}.#{table_name}"
    if query.present?
      query_string = query.map { |q| query_string(q[:key], q[:values]) }.join(" AND ")
      string = [ string, query_string ].join(" WHERE ")
    end

    return string
  end

  def select_fields(fields)
    fields.join(", ")
  end

  def query_string(key, values)
    arr = []
    values.each do |v|
    arr << "#{key} = '#{v}'"
    end

    arr.join(" OR ")
  end
end
