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

  def self.list_contacts
    response = HTTParty.get("#{@api_url}/crm/v3/objects/contacts?limit=100&hapikey=#{@api_key}")
    next_link = response.parsed_response["paging"]["next"]["link"] rescue nil

    data = response.parsed_response["results"]

    until next_link.blank?
      response = HTTParty.get("#{next_link}&hapikey=#{@api_key}")
      next_link = response.parsed_response["paging"]["next"]["link"] rescue nil

      data += response.parsed_response["results"]
    end

    return data
  end

  def self.delete_contact(vid)
    res = HTTParty.delete("#{@contacts_api_url}/vid/#{vid}?hapikey=#{@api_key}")
    res && res.parsed_response
  end

  def self.delete_contact_by_email(email)
    response = get_contact(email)
    if (response && response["vid"])
      res = delete_contact(response["vid"])
    end

    return res
  end

  def self.formatted_data(data, k)
    obj = { property: k, value: data[k] }

    date_keys = ["birthdate", "open_date", "next_due"]
    if date_keys.include?(k)
      obj[:value] = obj[:value].to_datetime.utc.at_beginning_of_day.to_i * 1000
    end

    obj
  end
end
