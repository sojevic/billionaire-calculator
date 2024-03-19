# lib/debt.rb
class Debt
    attr_reader :amount, :interest_rate, :repayment_period
    attr_accessor :remaining_balance
  
    def initialize(amount, interest_rate, repayment_period)
      @amount = amount
      @interest_rate = interest_rate
      @repayment_period = repayment_period
      @remaining_balance = amount
    end
  
    def annual_payment
      interest = remaining_balance * interest_rate
      principal = (amount / repayment_period.to_f)
      interest + principal
    end
  end