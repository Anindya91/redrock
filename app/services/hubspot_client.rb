class HubspotClient
  @api_key = Rails.application.credentials[:hubspot_api_key]
  @api_url = "https://api.hubapi.com"
  @contacts_api_url = "#{@api_url}/contacts/v1/contact"

  def self.get_contact(email)
    response = HTTParty.get("#{@contacts_api_url}/email/#{email}/profile?hapikey=#{@api_key}")
    response.parsed_response
  end

  def self.update_contact(email, data)
    properties = data.keys.map { |k| formatted_data(data, k) }
    return if properties.blank?

    response = HTTParty.post(
      "#{@contacts_api_url}/createOrUpdate/email/#{email}/?hapikey=#{@api_key}",
      body: { properties: properties }.to_json,
      headers: {
        "Content-Type" => "application/json",
        "Access-Control-Allow-Origin" => "*"
      }
    )

    if response.parsed_response && response.parsed_response["validationResults"].present?
      raise "HubspotError: #{response.parsed_response["validationResults"][0]["message"]}"
    end

    response
  end

  def self.delete_contact(email)
    # response = get_contact(email)
    # if (response && response["vid"])
    #   res = HTTParty.delete("#{@contacts_api_url}/vid/#{response["vid"]}?hapikey=#{@api_key}")
    # end
    # res && res.parsed_response
  end

  def self.formatted_data(data, k)
    obj = { property: k, value: data[k] }

    date_keys = ["birthdate"]
    if date_keys.include?(k)
      obj[:value] = obj[:value].to_datetime.utc.at_beginning_of_day.to_i * 1000
    end

    obj
  end
end
