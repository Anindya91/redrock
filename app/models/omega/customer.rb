class Omega::Customer < Omega
  attr_reader :id, :first_name, :middle_name, :last_name, :email_address,
    :birthday, :phone_numbers, :addresses, :sex, :marital_status,
    :number_of_dependents, :primary_address_as_of_date

  def initialize(params, client)
    @id = params[:id]
    @first_name = params[:first_name]
    @middle_name = params[:middle_name]
    @last_name = params[:last_name]
    @email_address = params[:email_address]
    @birthday = params[:birthday]
    @sex = params[:sex]
    @marital_status = params[:marital_status]
    @number_of_dependents = params[:number_of_dependents]
    if @id.present?
      @phone_numbers = client.get_phone_numbers(@id, keep_alive: true)
      @addresses = client.get_addresses(@id, keep_alive: true)
    end
  end
end
