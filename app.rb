require 'sinatra'
require 'erb'
require 'action_view'
require_relative 'financial_data'

include ActionView::Helpers::NumberHelper

DATA_FILE = 'data.json'
TAX_RATE = 25.0
TABLE_YEARS = 25

configure do
  $financial_data = FinancialData.new(0, 0, TAX_RATE)
  $financial_data.load_from_file(DATA_FILE) if File.exist?(DATA_FILE)
end

get '/' do
  if File.exist?(DATA_FILE)
    $financial_data.calculate(TABLE_YEARS)
    erb :index
  else
    $financial_data = FinancialData.new(0, 0, TAX_RATE)
    erb :index
  end
end

############################################################
####################### BUSINESSES #########################
############################################################

post '/add_business' do
  business_name = params[:business_name]
  initial_income = params[:initial_income].to_f
  growth_rates = (1..6).map { |i| params["income_growth_rate_#{i}"].to_f }
  start_year = params[:start_year].to_i

  $financial_data.add_business(business_name, initial_income, growth_rates, start_year)
  $financial_data.calculate(TABLE_YEARS)
  $financial_data.save_to_file(DATA_FILE)
  redirect '/'
end

post '/calculate' do
  # Retrieve user inputs from the form
  initial_income = params[:initial_income].to_f
  income_growth_rate = params[:income_growth_rate].to_f
  tax_rate = params[:tax_rate].to_f

  # Create an instance of the FinancialData class
  financial_data = FinancialData.new(initial_income, income_growth_rate, tax_rate)

  # Calculate the financial information for each year
  financial_data.calculate(TABLE_YEARS)

  # Pass the calculated data to the results template
  erb :results, locals: { financial_data: financial_data }
end

get '/edit_business/:index' do
  index = params[:index].to_i
  @business = $financial_data.businesses[index]
  erb :edit_business
end

post '/update_business/:index' do
  index = params[:index].to_i
  business_name = params[:business_name]
  initial_income = params[:initial_income].to_f
  growth_rates = (1..6).map { |i| params["income_growth_rate_#{i}"].to_f }
  start_year = params[:start_year].to_i

  $financial_data.update_business(index, business_name, initial_income, growth_rates, start_year)
  $financial_data.calculate(TABLE_YEARS)
  $financial_data.save_to_file(DATA_FILE)
  redirect '/'
end

delete '/delete_business/:index' do
  index = params[:index].to_i
  $financial_data.delete_business(index)
  $financial_data.calculate(TABLE_YEARS)
  $financial_data.save_to_file(DATA_FILE)
  redirect '/'
end

############################################################
########################## DEBTS ###########################
############################################################

post '/add_debt' do
  debt_name = params[:debt_name]
  debt_amount = params[:debt_amount].to_f
  interest_rate = params[:interest_rate].to_f
  repayment_period = params[:repayment_period].to_i
  pay_back_asap = params[:pay_back_asap] == 'on'
  start_year = params[:debt_start_year].to_i

  $financial_data.add_debt(debt_name, debt_amount, interest_rate, repayment_period, pay_back_asap, start_year)
  $financial_data.calculate(TABLE_YEARS)
  $financial_data.save_to_file(DATA_FILE)
  redirect '/'
end

get '/edit_debt/:index' do
  index = params[:index].to_i
  @debt = $financial_data.debts[index]
  erb :edit_debt
end

post '/update_debt/:index' do
  index = params[:index].to_i
  debt_name = params[:debt_name]
  debt_amount = params[:debt_amount].to_f
  interest_rate = params[:interest_rate].to_f
  repayment_period = params[:repayment_period].to_i
  pay_back_asap = params[:pay_back_asap] == 'on'
  start_year = params[:debt_start_year].to_i

  $financial_data.update_debt(index, debt_name, debt_amount, interest_rate, repayment_period, pay_back_asap, start_year)
  $financial_data.calculate(TABLE_YEARS)
  $financial_data.save_to_file(DATA_FILE)
  redirect '/'
end

delete '/delete_debt/:index' do
  index = params[:index].to_i
  $financial_data.delete_debt(index)
  $financial_data.calculate(TABLE_YEARS)
  $financial_data.save_to_file(DATA_FILE)
  redirect '/'
end