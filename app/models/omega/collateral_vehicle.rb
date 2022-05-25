class Omega::CollateralVehicle < Omega
  attr_reader :id, :year, :make, :model, :mileage, :vin, :license_number

  def initialize(params, client)
    @id = params[:id]
    @year = params[:year]
    @make = params[:make]
    @model = params[:model]
    @mileage = params[:mileage]
    @vin = params[:vin]
    @license_number = params[:license_number]
  end
end
