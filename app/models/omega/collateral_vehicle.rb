class Omega::CollateralVehicle < Omega
  attr_reader :id, :year, :make, :model, :mileage, :vin

  def initialize(params, client)
    @id = params[:id]
    @year = params[:year]
    @make = params[:make]
    @model = params[:model]
    @mileage = params[:mileage]
    @vin = params[:vin]
  end
end
