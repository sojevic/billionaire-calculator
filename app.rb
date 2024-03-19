# app.rb
require 'sinatra'
require 'sinatra/contrib'
require 'json'

require_relative 'lib/business'
require_relative 'lib/debt'
require_relative 'lib/calculator'

set :public_folder, File.dirname(__FILE__) + '/public'
set :views, File.dirname(__FILE__) + '/views'

get '/' do
  erb :index
end

post '/calculate' do
  puts "Received POST request to /calculate"
  begin
    data = JSON.parse(request.body.read)
    puts "Received form data: #{data}"

    initial_income = data['initial-income'].to_f
    existing_debt = data['existing-debt'].to_f

    # Improved validation and error handling
    if initial_income <= 0 || existing_debt < 0
      status 400
      return { error: "Initial income must be greater than 0 and existing debt cannot be negative" }.to_json
    end

    tax_rate = data['tax-rate'].to_f / 100
    inflation_rate = data['inflation-rate'].to_f / 100

    calculator = Calculator.new(initial_income, existing_debt, tax_rate, inflation_rate)

    data.each do |key, value|
      if key.start_with?('business-')
        business_id = key.split('-')[1]
        next if business_id.nil? || business_id.empty? || business_id == "0"
        business_id = business_id.to_i

        name = data["business-#{business_id}-name"]
        acquisition_year = data["business-#{business_id}-acquisition-year"].to_i
        investment_amount = data["business-#{business_id}-investment-amount"].to_f
        initial_income = data["business-#{business_id}-initial-income"].to_f
        growth_rates = {}
        data.each do |growth_rate_key, growth_rate_value|
          next unless growth_rate_key.start_with?("business-#{business_id}-growth-rate-")
          year = growth_rate_key.split('-').last.to_i
          growth_rates[year + acquisition_year] = growth_rate_value.to_f / 100
        end
        calculator.add_business(name, acquisition_year, investment_amount, initial_income, growth_rates)
      elsif key.start_with?('debt-')
        debt_id = key.split('-')[1]
        next if debt_id.nil? || debt_id.empty?

        debt_id = debt_id.to_i
        amount = data["debt-#{debt_id}-amount"].to_f
        interest_rate = data["debt-#{debt_id}-interest-rate"].to_f / 100
        repayment_period = data["debt-#{debt_id}-repayment-period"].to_i
        calculator.add_debt(amount, interest_rate, repayment_period)
      end
    end

    net_worth_progression = {}
    (0..50).each do |year|
      net_worth_progression[year] = calculator.calculate_net_worth(year)
    end

    year_to_reach_target = nil
    net_worth_progression.each do |year, net_worth|
      if calculator.annual_profit(year) >= 50_000_000
        year_to_reach_target = year
        break
      end
    end

    result = {
      netWorthProgression: net_worth_progression.map { |year, net_worth| "Year #{year}: $#{net_worth.round(2)}" }.join("\n"),
      yearToReachTarget: year_to_reach_target || "Target not reached within 50 years"
    }

    content_type :json
    result.to_json
  rescue => e
    puts "Error: #{e.class} - #{e.message}\n#{e.backtrace.join("\n")}"
    status 500
    { error: "An error occurred: #{e.message}" }.to_json
  end
end
