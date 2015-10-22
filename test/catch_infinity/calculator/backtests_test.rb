require 'test_helper'
require_relative '../../../lib/catch_infinity/calculator/backtests'

class BacktestsTest < ActionController::TestCase
	def setup
		@tesla = stocks(:tesla)
		@google = stocks(:google)
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
			assert_equal answers[:value_end].to_f, 10024.52002
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

	test "should output trade hashes for backtest" do
		VCR.use_cassette("yahoo_finance") do
			options = {
				query_start: DateTime.new(2015,10,19),
				query_end: (DateTime.new(2015,10,19) - 1.year),
				value_start: 10000,
				dollar_cost_average: false,
				sell_signal: "p>20>50",
				buy_signal: "p<20<50",
				stocks: [@tesla, @google]
			}		
			calculator = Calculator::Backtests.new(options)
			answers = calculator.calculate

			assert_equal answers[:trades_array].count, 6
			answers[:trades_array].each do |trade|
				assert_not_nil trade[:sell_price]
				assert_not_nil trade[:sell_date]
			end
		end
	end
end