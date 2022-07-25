class Omega::AccountInstallment < Omega
  attr_reader :id, :next_due_date, :total_current_balance, :number_of_whole_payments, :down_payment_amount, :contractual_amount_financed, :contractual_actual_term, :current_rate, :regular_payment_amount, :cash_price

  def initialize(params, client)
    @id = params[:id]
    @next_due_date = params[:next_due_date]
    @total_current_balance = params[:total_current_balance]
    @number_of_whole_payments = params[:number_of_whole_payments]
    @down_payment_amount = params[:down_payment_amount]
    @contractual_amount_financed = params[:contractual_amount_financed]
    @contractual_actual_term = params[:contractual_actual_term]
    @current_rate = params[:current_rate]
    @regular_payment_amount = params[:regular_payment_amount]
    @cash_price = params[:cash_price]
  end
end
