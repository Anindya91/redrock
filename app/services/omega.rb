class Omega
  BATCH_SIZE = 100

  def get_accounts
    data = []
    ids = []

    client = get_client
    10000.times do |i|
      query_string = "SELECT TOP(#{ids.count+batch_size}) * FROM Common.Account"
      if ids.present?
        query_string = "#{query_string} EXCEPT SELECT TOP(#{ids.count}) * FROM Common.Account"
      end

      result = client.execute(query_string)
      new_ids = []
      result.each do |r|
        data << r
        new_ids << r["Id"]
      end
      break if new_ids.blank?
      ids += new_ids
    end
    client.close

    return data
  end

  private

  def get_client
    TinyTds::Client.new(
      username: Rails.application.credentials.omega_username,
      password: Rails.application.credentials.omega_password,
      host: Rails.application.credentials.omega_host,
      database: Rails.application.credentials.omega_database
    )
  end
end
