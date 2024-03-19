require 'sinatra'
require 'erb'
require 'action_view'
require_relative 'financial_data'

include ActionView::Helpers::NumberHelper

get '/' do
  erb :index
end

post '/calculate' do
  # Retrieve user inputs from the form
  initial_income = params[:initial_income].to_f
  income_growth_rate = params[:income_growth_rate].to_f
  tax_rate = params[:tax_rate].to_f

  # Create an instance of the FinancialData class
  financial_data = FinancialData.new(initial_income, income_growth_rate, tax_rate)

  # Calculate the financial information for each year
  financial_data.calculate(50)

  # Pass the calculated data to the results template
  erb :results, locals: { financial_data: financial_data }
end