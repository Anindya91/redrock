class Omega::RemarkCode < Omega
  attr_reader :id, :code, :enhanced, :description

  def initialize(params, client)
    @id = params[:id]
    @code = params[:code]
    @description = params[:description]
    @enhanced = params[:enhanced]
  end
end
