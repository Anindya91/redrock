class Omega::AccountInstallment < Omega
  attr_reader :id, :next_due_date, :total_current_balance, :number_of_whole_payments

  def initialize(params, client)
    @id = params[:id]
    @next_due_date = params[:next_due_date]
    @total_current_balance = params[:total_current_balance]
    @number_of_whole_payments = params[:number_of_whole_payments]
  end
end
