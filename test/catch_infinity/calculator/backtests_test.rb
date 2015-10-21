require 'test_helper'
require_relative '../../../lib/catch_infinity/calculator/backtests'

class BacktestsTest < ActionController::TestCase
	def setup
		@tesla = stocks(:tesla)
	end

	test "return a number of trades" do
		VCR.use_cassette("yahoo_finance") do
			options = {
				query_start: DateTime.new(2015,10,19),
				query_end: (DateTime.new(2015,10,19) - 1.year),
				value_start: 10000,
				dollar_cost_average: false,
				sell_signal: "p>20>50",
				buy_signal: "p<20<50",
				stocks: [@tesla]
			}
			calculator = Calculator::Backtests.new(options)
			answers = calculator.calculate
			assert_equal answers[:value_end].to_f, 49271.909762
		end
	end

	test "fetches historical stock data if needed" do
		VCR.use_cassette("yahoo_finance") do
			options = {
				query_start: DateTime.new(2015,10,19),
				query_end: (DateTime.new(2015,10,19) - 1.year),
				value_start: 10000,
				dollar_cost_average: false,
				sell_signal: "p>20>50",
				buy_signal: "p<20<50",
				stocks: [@tesla]
			}
			assert_operator @tesla.histories.order(date: :asc).first.date, :>=, 1.year.ago
			
			calculator = Calculator::Backtests.new(options)
			answers = calculator.calculate

			assert_operator @tesla.histories.order(date: :asc).first.date, :<=, 1.year.ago
		end
	end
end