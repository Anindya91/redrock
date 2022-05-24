class Omega
  BATCH_SIZE = 1000

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
    ids = []

    100.times do |i|
      query_string = "SELECT TOP(#{ids.count + BATCH_SIZE}) * FROM Common.Account"
      if ids.present?
        query_string = "#{query_string} EXCEPT SELECT TOP(#{ids.count}) * FROM Common.Account"
      end

      result = @client.execute(query_string)
      new_ids = []
      result.each do |r|
        data << r
        new_ids << r["Id"]
      end
      break if new_ids.blank?
      ids += new_ids
    end

    close_connection and return data
  end

  private

  def close_connection
    @client.close
  end
end
