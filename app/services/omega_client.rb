class OmegaClient
  ACTIVE_CODES = %w(A AV)

  def initialize
    @client = TinyTds::Client.new(
      username: Rails.application.credentials.omega_username,
      password: Rails.application.credentials.omega_password,
      host: Rails.application.credentials.omega_host,
      database: Rails.application.credentials.omega_database
    )
  end

  def get_active_accounts
    result = @client.execute("SELECT Id FROM Common.AdminStatus WHERE #{query_string("Code", ACTIVE_CODES)}")
    status_ids = result.to_a.map { |s| s["Id"] }

    query_string = "SELECT * FROM Common.Account WHERE #{query_string("AdminStatusId", status_ids)}"
    result = @client.execute(query_string)
    data = result.to_a

    close_connection and return data
  end

  def get_customer(customer_id)
    fields = ["Id", "FirstName", "MiddleName", "LastName", "EmailAddress", "Birthday"]
    result = sql_execute("Customer", fields: fields, query_key: "Id", query_values: [customer_id])
    data = symbolize_data(result.to_a, class_name: "Omega::Customer")

    close_connection and return data
  end

  def get_phone_numbers(customer_id)
    result = sql_execute("PhoneNumber", query_key: "ParentId", query_values: [customer_id])
    data = symbolize_data(result.to_a, class_name: "Omega::PhoneNumber")

    close_connection and return data
  end

  def get_addresses(customer_id)
    result = sql_execute("Address", query_key: "ParentId", query_values: [customer_id])
    data = symbolize_data(result.to_a, class_name: "Omega::Address")

    close_connection and return data
  end

  private

  def symbolize_data(data, class_name: nil)
    new_data = data.map { |d| d.deep_transform_keys { |key| key.underscore }.symbolize_keys }
    if class_name.present?
      new_data = new_data.map { |d| class_name.constantize.new(d) }
    end

    return new_data
  end

  def close_connection
    @client.close
  end

  def sql_execute(table_name, fields: ["*"], query_key: nil, query_values: [], schema: "Common")
    @client.execute(sql_select_command(fields, table_name, query_key, query_values, schema))
  end

  def sql_select_command(fields, table_name, query_key, query_values, schema)
    string = "SELECT #{select_fields(fields)} FROM #{schema}.#{table_name}"
    if query_key.present? && query_values.present?
      string = "#{string} WHERE #{query_string(query_key, query_values)}"
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
