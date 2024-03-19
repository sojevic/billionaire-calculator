# lib/calculator.rb
require_relative 'business'
require_relative 'debt'

class Calculator
  attr_reader :businesses, :debts, :tax_rate, :inflation_rate

  def initialize(initial_income, initial_debt, tax_rate, inflation_rate)
    @businesses = []
    @businesses << Business.new('Initial Business', 0, 0, initial_income, {})
    @debts = []
    @debts << Debt.new(initial_debt, 0, 1) if initial_debt > 0
    @tax_rate = tax_rate
    @inflation_rate = inflation_rate
  end

  def add_business(name, acquisition_year, investment_amount, initial_income, growth_rates)
    @businesses << Business.new(name, acquisition_year, investment_amount, initial_income, growth_rates)
  end

  def add_debt(amount, interest_rate, repayment_period)
    @debts << Debt.new(amount, interest_rate, repayment_period)
  end

  def calculate_net_worth(year)
    puts "Calculating net worth for year: #{year}"
    net_worth = 0
    @businesses.each do |business|
      projected_income = business.project_income(year)
      puts "Projected income for #{business.name} in year #{year}: #{projected_income}"
      net_worth += projected_income * (1 - tax_rate)
    end

    @debts.each do |debt|
      debt.remaining_balance -= debt.annual_payment
      net_worth -= debt.remaining_balance
    end

    net_worth / (1 + inflation_rate)**(year - 0)
  end

  def annual_profit(year)
    total_income = 0
    @businesses.each do |business|
      total_income += business.project_income(year)
    end
    total_income * (1 - tax_rate)
  end

  def calculate_yearly_financials(year)
    yearly_financials = {year: year, investments: 0, savings: 0}
    
    # Income Before and After Tax
    total_income_before_tax = businesses.sum { |business| business.project_income(year) }
    total_income_after_tax = total_income_before_tax * (1 - tax_rate)
    yearly_financials[:income_before_tax] = total_income_before_tax
    yearly_financials[:income_after_tax] = total_income_after_tax
    
    # Debt
    total_debt = debts.sum(&:remaining_balance)
    yearly_financials[:debt] = total_debt

    # Assuming investments are the sum of investment_amount for businesses acquired in the specific year
    yearly_investments = businesses.select { |b| b.acquisition_year == year }.sum(&:investment_amount)
    yearly_financials[:investments] = yearly_investments

    # Savings could be defined as income after tax and debt payments - adjust according to your logic
    total_debt_payment = debts.sum(&:annual_payment)
    yearly_savings = total_income_after_tax - total_debt_payment
    yearly_financials[:savings] = yearly_savings > 0 ? yearly_savings : 0

    yearly_financials
  end
end