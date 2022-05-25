class Omega::PhoneNumber < Omega
  attr_reader :id, :phone_number, :phone_number_type, :call_ok, :primary, :text_ok

  def initialize(params)
    @id = params[:id]
    @phone_number = params[:phone_number]
    @phone_number_type = params[:phone_number_type]
    @call_ok = params[:call_ok]
    @primary = params[:primary]
    @text_ok = params[:text_ok]
  end
end
