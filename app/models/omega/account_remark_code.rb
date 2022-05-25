class Omega::AccountRemarkCode < Omega
  attr_reader :id, :remark_code

  def initialize(params, client)
    @id = params[:id]
    if params[:remark_code_id].present?
      @remark_code = params[:map][:remark_codes].find { |rc| rc.id == params[:remark_code_id] }
    end
  end
end
