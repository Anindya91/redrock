class NeoVerifyClient
  API_URL = "https://api.neoverify.com/v1/"

  def initialize(account)
    @account = account
    @data = account.neo_verify_object
  end

  def create_or_update_applcation
    response = send_request("update_application", @data, "put")
    return response.parsed_response if response.code == 202

    response = send_request("create_application", @data, "post")
    response.parsed_response
  end

  private

  def send_request(path, body, method_name)
    HTTParty.send(
      method_name,
      File.join(API_URL, path),
      body: body.to_json,
      headers: {
        "Accept" => "application/json",
        "Content-Type" => "application/json",
        "Access-Token" => Rails.application.credentials[:neo_api_key]
      }
    )
  end
end
