class Omega::Province < Omega
  attr_reader :id, :abbreviation, :name, :country

  def initialize(params, client)
    @id = params[:id]
    @abbreviation = params[:abbreviation]
    @name = params[:name]
    if params[:country_id].present?
      @country = client.get_country(params[:country_id], keep_alive: true)
    end
  end
end
