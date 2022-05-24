class Omega
  BATCH_SIZE = 50000
  def initialize
    @client = TinyTds::Client.new(
      username: Rails.application.credentials.omega_username,
      password: Rails.application.credentials.omega_password,
      host: Rails.application.credentials.omega_host,
      database: Rails.application.credentials.omega_database
    )
  end

  def get_accounts
    data = []
    query_string = "SELECT TOP(#{data.count + BATCH_SIZE}) * FROM Common.Account"
    result = @client.execute(query_string)
    result.each { |r| data << r }

    close_connection and return data
  end

  private

  def close_connection
    @client.close
  end
end
