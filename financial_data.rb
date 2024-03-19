class FinancialData
  attr_reader :data

  def initialize(initial_income, income_growth_rate, tax_rate)
    @initial_income = initial_income
    @income_growth_rate = income_growth_rate
    @tax_rate = tax_rate
    @data = []
  end

  def calculate(num_years)
    business_income_before_tax = @initial_income
    outstanding_debt = 0
    debt_repayments = 0
    bank_balance = 0
    new_investments = 0

    num_years.times do
      business_income_after_tax = business_income_before_tax * (1 - @tax_rate / 100)
      bank_balance += business_income_after_tax
      bank_balance -= debt_repayments
      bank_balance -= new_investments

      @data << {
        business_income_before_tax: business_income_before_tax,
        business_income_after_tax: business_income_after_tax,
        outstanding_debt: outstanding_debt,
        debt_repayments: debt_repayments,
        bank_balance: bank_balance,
        new_investments: new_investments
      }

      business_income_before_tax *= (1 + @income_growth_rate / 100)
    end
  end
end