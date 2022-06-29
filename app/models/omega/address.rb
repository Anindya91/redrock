class Omega::Address < Omega
  attr_reader :id, :active, :addr_line1, :addr_line2, :addr_line3, :city,
    :zip_code, :primary, :province, :address_type

  def initialize(params, client)
    @id = params[:id]
    @active = params[:active]
    @addr_line1 = params[:addr_line1]
    @addr_line2 = params[:addr_line2]
    @addr_line3 = params[:addr_line3]
    @city = params[:city]
    @zip_code = params[:zip_code]
    @primary = params[:primary]
    @address_type = params[:address_type]
    if params[:province_id].present?
      @province = client.get_province(params[:province_id], keep_alive: true)
    end
  end
end
