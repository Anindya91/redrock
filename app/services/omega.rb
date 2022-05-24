class Omega
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

    close_connection and return result.to_a
  end

  private

  def close_connection
    @client.close
  end

  def query_string(key, values)
    arr = []
    values.each do |v|
      arr << "#{key} = '#{v}'"
    end

    arr.join(" OR ")
  end
end
