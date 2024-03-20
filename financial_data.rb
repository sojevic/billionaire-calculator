class FinancialData
  attr_reader :data, :businesses, :debts

  def initialize(initial_income, income_growth_rate, tax_rate)
    @businesses = []
    @tax_rate = tax_rate
    @data = []
    @debts = []
  end

  def add_business(name, initial_income, growth_rates)
    @businesses << { name: name, initial_income: initial_income, growth_rates: growth_rates }
  end

  def update_business(index, name, initial_income, growth_rates)
    @businesses[index][:name] = name
    @businesses[index][:initial_income] = initial_income
    @businesses[index][:growth_rates] = growth_rates
  end

  def delete_business(index)
    @businesses.delete_at(index)
  end

  def calculate(num_years)
    @data = []
    debt_amounts = @debts.map { |debt| debt[:debt_amount] }
    bank_balance = 0
  
    num_years.times do |year|
      business_incomes = @businesses.map do |business|
        income = business[:initial_income]
        (0..year).each do |y|
          growth_rate = y < 5 ? business[:growth_rates][y] : business[:growth_rates][5]
          income *= (1 + growth_rate / 100)
        end
        { name: business[:name], income: income }
      end
  
      business_income_before_tax = business_incomes.sum { |income| income[:income] }
      total_interest_payment = 0
      total_principal_payment = 0
  
      @debts.each_with_index do |debt, index|
        remaining_years = debt[:repayment_period] - year
        if remaining_years > 0
          annual_payment = debt_amounts[index] * (debt[:interest_rate] / 100) / (1 - (1 + debt[:interest_rate] / 100)**(-remaining_years))
          interest_payment = debt_amounts[index] * (debt[:interest_rate] / 100)
          principal_payment = annual_payment - interest_payment
  
          total_interest_payment += interest_payment
          total_principal_payment += principal_payment
  
          if debt[:pay_back_asap] && business_income_before_tax >= annual_payment
            debt_amounts[index] -= principal_payment
          else
            debt_amounts[index] -= principal_payment
          end
        end
      end
  
      business_income_before_tax -= total_interest_payment
      business_income_after_tax = business_income_before_tax * (1 - @tax_rate / 100)
  
      outstanding_debt = debt_amounts.sum
      debt_repayments = total_principal_payment
  
      bank_balance += business_income_after_tax - debt_repayments
      new_investments = 0
  
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

  def add_debt(debt_amount, interest_rate, repayment_period, pay_back_asap)
    @debts << {
      debt_amount: debt_amount,
      interest_rate: interest_rate,
      repayment_period: repayment_period,
      pay_back_asap: pay_back_asap
    }
  end

  def update_debt(index, debt_amount, interest_rate, repayment_period, pay_back_asap)
    @debts[index][:debt_amount] = debt_amount
    @debts[index][:interest_rate] = interest_rate
    @debts[index][:repayment_period] = repayment_period
    @debts[index][:pay_back_asap] = pay_back_asap
  end

  def delete_debt(index)
    @debts.delete_at(index)
  end
end

