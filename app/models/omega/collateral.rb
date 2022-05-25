class Omega::Collateral < Omega
  attr_reader :id, :collateral_type, :collateral_vehicle

  def initialize(params, client)
    @id = params[:id]
    @collateral_type = params[:collateral_type]

    if @id.present?
      if @collateral_type == 1
        @collateral_vehicle = client.get_collateral_vehicle(@id, keep_alive: true)
      end
    end
  end
end
