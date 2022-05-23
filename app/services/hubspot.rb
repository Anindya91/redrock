class Hubspot
  @api_key = Rails.application.credentials[:hubspot][:api_key]
  @api_url = "https://api.hubapi.com"
  @contacts_api_url = "#{@api_url}/contacts/v1/contact"

  def self.get_contact(email)
    response = HTTParty.get("#{@contacts_api_url}/email/#{email}/profile?hapikey=#{@api_key}")
    response.parsed_response
  end

  def self.update_contact(meta, data)
    properties = data.keys.map { |k| formatted_data(data, k) }
    if meta["name"].present?
      properties.push({ property: "firstname", value: meta["name"].split(" ")[0] })
      properties.push({ property: "lastname", value: meta["name"].split(" ")[1..-1].join(" ") })
    end
    return if properties.blank?

    response = HTTParty.post(
      "#{@contacts_api_url}/createOrUpdate/email/#{meta["email"]}/?hapikey=#{@api_key}",
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

  def self.update_email(old_email, new_email)
    response = HTTParty.post(
      "#{@contacts_api_url}/email/#{old_email}/profile?hapikey=#{@api_key}",
      body: { properties: [{ property: "email", value: new_email }] }.to_json,
      headers: {
        "Content-Type" => "application/json",
        "Access-Control-Allow-Origin" => "*"
      }
    )

    if response.parsed_response && response.parsed_response["status"] == "error"
      raise "HubspotError: #{response.parsed_response["message"]}"
    end

    response
  end

  def self.delete_contact(email)
    response = get_contact(email)
    if (response && response["vid"])
      res = HTTParty.delete("#{@contacts_api_url}/vid/#{response["vid"]}?hapikey=#{@api_key}")
    end
    res && res.parsed_response
  end

  def self.formatted_data(data, k)
    obj = { property: k, value: data[k] }

    date_keys = ["last_referral_date", "trial_expiration"]
    if date_keys.include?(k)
      obj[:value] = obj[:value].to_datetime.utc.at_beginning_of_day.to_i * 1000
    end

    obj
  end
end
