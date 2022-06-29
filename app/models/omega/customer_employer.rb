class Omega::CustomerEmployer < Omega
  attr_reader :id, :employer_name, :start_date, :is_active, :salary,
    :salary_frequency, :occupation, :end_date, :salary_hours

  def initialize(params, client)
    @id = params[:id]
    @employer_name = params[:employer_name]
    @start_date = params[:start_date]
    @is_active = params[:is_active]
    @salary = params[:salary]
    @salary_frequency = params[:salary_frequency]
    @occupation = params[:occupation]
    @end_date = params[:end_date]
    @salary_hours = params[:salary_hours]
  end
end
