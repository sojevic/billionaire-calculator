class FinancialData
  attr_reader :data

  def initialize(initial_income, income_growth_rate, tax_rate)
    @businesses = []
    @tax_rate = tax_rate
    @data = []
  end

  def add_business(name, initial_income, income_growth_rate)
    @businesses << { name: name, initial_income: initial_income, income_growth_rate: income_growth_rate }
  end

  def calculate(num_years)
    @data = []
    outstanding_debt = 0
    debt_repayments = 0
    bank_balance = 0
    new_investments = 0

    num_years.times do |year|
      business_incomes = @businesses.map do |business|
        income = business[:initial_income] * (1 + business[:income_growth_rate] / 100) ** year
        { name: business[:name], income: income }
      end

      business_income_before_tax = business_incomes.sum { |income| income[:income] }
      business_income_after_tax = business_income_before_tax * (1 - @tax_rate / 100)
      bank_balance += business_income_after_tax
      bank_balance -= debt_repayments
      bank_balance -= new_investments

      @data << {
        business_incomes: business_incomes,
        business_income_before_tax: business_income_before_tax,
        business_income_after_tax: business_income_after_tax,
        outstanding_debt: outstanding_debt,
        debt_repayments: debt_repayments,
        bank_balance: bank_balance,
        new_investments: new_investments
      }
    end
  end
end