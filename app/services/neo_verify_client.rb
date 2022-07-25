class NeoVerifyClient
  API_URL = "https://api.neoverify.com/v1/"

  def initialize(account)
    @account = account
    @data = account.neo_verify_object
  end

  def create_or_update_applcation(account)
    response = post_request("update_application", @data)
    return response.parsed_response if response.code == 202

    response = post_request("create_application", data)
    response.parsed_response
  end

  private

  def post_request(method_name, body)
    HTTParty.post(
      File.join(API_URL, method_name),
      body: body.to_json,
      headers: {
        "Accept" => "application/json",
        "Content-Type" => "application/json",
        "Access-Token" => Rails.application.credentials[:neo_api_key]
      }
    )
  end
end
