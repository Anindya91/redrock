class Omega::Customer < Omega
  attr_reader :id, :first_name, :middle_name, :last_name, :email_address, :birthday, :phone_numbers, :addresses

  def initialize(params)
    @id = params[:id]
    @first_name = params[:first_name]
    @middle_name = params[:middle_name]
    @last_name = params[:last_name]
    @email_address = params[:email_address]
    @birthday = params[:birthday]
    if @id.present?
      @phone_numbers = OmegaClient.new.get_phone_numbers(@id)
      @addresses = OmegaClient.new.get_addresses(@id)
    end
  end
end
