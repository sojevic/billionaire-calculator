# lib/business.rb
class Business
    attr_reader :name, :acquisition_year, :investment_amount, :growth_rates
    attr_accessor :income
  
    def initialize(name, acquisition_year, investment_amount, initial_income, growth_rates)
      @name = name
      @acquisition_year = acquisition_year
      @investment_amount = investment_amount
      @income = initial_income
      @growth_rates = growth_rates
    end
  
    def project_income(year)
      income_for_year = @income  # Ensure this is initialized to a non-nil numeric value.
      (@acquisition_year+1..year).each do |yr|
        growth_rate = @growth_rates[yr] || 0  # Use 0 as a default if the growth rate for the year is nil.
        income_for_year *= (1 + growth_rate)
      end
      income_for_year
    end

  end