class Omega::Country < Omega
  attr_reader :id, :country_name

  def initialize(params, client)
    @id = params[:id]
    @country_name = params[:country_name]
  end
end
