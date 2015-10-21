module Calculator
	class Backtests
		attr_reader :query_start
		attr_reader :query_end
		attr_reader :value_start
		attr_reader :dollar_cost_average
		attr_reader :sell_signal
		attr_reader :buy_signal
		attr_reader :stocks

		QUERY_START_BUFFER = 1.week
		QUERY_END_BUFFER = 1.day.ago

		def initialize(options = {})
			@query_start = options[:query_start] || 1.year.ago
			@query_end = options[:query_end] || Time.now
			@value_start = options[:value_start]
			@dollar_cost_average = options[:dollar_cost_average]
			@sell_signal = options[:sell_signal]
			@buy_signal = options[:buy_signal]
			@stocks = options[:stocks]
		end

		def calculate
			# guard_clauses
			check_and_fetch_missing_histories
			grind_numbers
		end


		private
		
		def grind_numbers
			collected_histories = collect_stock_histories
			history_run(collected_histories)
		end

		def history_run(collected_histories)
			calculator_numbers = {
					avg_20_day: {},
					avg_50_day: {},
					stock_holdings: {},
					value_end: @value_start
			}
			collected_histories.each do |day, histories|
				histories.each do |k, v|
					calculator_numbers = change_moving_averages(k, v, calculator_numbers)
					calculator_numbers = adjust_holdings(k, v, calculator_numbers)
				end
			end
			# liquidate excess holdings
			puts calculator_numbers[:stock_holdings]
			return calculator_numbers
		end

		def change_moving_averages(key, value, calculator_numbers)
			calculator_numbers = move_20_day(key, value, calculator_numbers)
			calculator_numbers = move_50_day(key, value, calculator_numbers)
		end

		def move_20_day(key, value, calculator_numbers)
			calculator_numbers[:avg_20_day][key] = [] unless calculator_numbers[:avg_20_day][key]
			calculator_numbers[:avg_20_day][key] << value
			calculator_numbers[:avg_20_day][key].shift if calculator_numbers[:avg_20_day][key].count > 20
			return calculator_numbers
		end

		def move_50_day(key, value, calculator_numbers)
			calculator_numbers[:avg_50_day][key] = [] unless calculator_numbers[:avg_50_day][key]
			calculator_numbers[:avg_50_day][key] << value
			calculator_numbers[:avg_50_day][key].shift if calculator_numbers[:avg_50_day][key].count > 50
			return calculator_numbers
		end

		def adjust_holdings(key, value, calculator_numbers)
			calculator_numbers = buy(key, value, calculator_numbers) if not_holding?(key, calculator_numbers) && have_money?(calculator_numbers) && should_buy?(key, value, calculator_numbers)
			calculator_numbers = sell(key, value, calculator_numbers) if !not_holding?(key, calculator_numbers) && should_sell?(key, value, calculator_numbers)
			return calculator_numbers
		end

		def should_sell?(key, value, calculator_numbers)
			avg50 = BigDecimal.new(calculator_numbers[:avg_50_day][key].sum)/BigDecimal.new(calculator_numbers[:avg_50_day][key].count)
			avg20 = BigDecimal.new(calculator_numbers[:avg_20_day][key].sum)/BigDecimal.new(calculator_numbers[:avg_20_day][key].count)
			return true if value > avg20 && avg20 > avg50
		end 

		def sell(key, value, calculator_numbers)
			calculator_numbers[:value_end] += (calculator_numbers[:stock_holdings][key]*value)
			calculator_numbers[:stock_holdings][key] = 0
			return calculator_numbers
		end

		def not_holding?(key, calculator_numbers)
			calculator_numbers[:stock_holdings][key] ||= 0
			return true if calculator_numbers[:stock_holdings][key] == 0
			return false
		end

		def have_money?(calculator_numbers)
			return true if calculator_numbers[:value_end] > 1
		end

		def should_buy?(key, value, calculator_numbers)
			avg50 = BigDecimal.new(calculator_numbers[:avg_50_day][key].sum)/BigDecimal.new(calculator_numbers[:avg_50_day][key].count)
			avg20 = BigDecimal.new(calculator_numbers[:avg_20_day][key].sum)/BigDecimal.new(calculator_numbers[:avg_20_day][key].count)
			return true if value < avg20 && avg20 < avg50
		end

		def buy(key, value, calculator_numbers)
			invest_value = calculate_invest_value(calculator_numbers[:value_end])
			quantity = (invest_value/value).floor
			calculator_numbers[:stock_holdings][key] += quantity
			calculator_numbers[:value_end] -= (quantity*value)
			return calculator_numbers
		end

		def calculate_invest_value(value_end)
			if value_end < @value_start*0.1
				value_end
			else
				@value_start*0.1
			end
		end


		def collect_stock_histories
			collected_histories = {}
			@stocks.each do |stock|
				stock.histories.each do |history|
					collected_histories[history.date] = {} unless collected_histories[history.date]
					collected_histories[history.date][history.stock_id] = history.price_day_close
				end		
			end
			return collected_histories
		end

		def check_and_fetch_missing_histories
			@stocks.each do |stock|
				histories = stock.histories.order(date: :asc)
				unless far_back_enough?(histories) and recent_enough?(histories)
					create_stock_histories(stock.ticker)
				end
			end
		end

		def far_back_enough?(histories)
			return true if histories.first.date < (@query_start - QUERY_START_BUFFER)
		end

		def recent_enough?(histories)
			return true if histories.last.date > QUERY_END_BUFFER
		end

		def create_stock_histories(ticker)
			options = {
				query_start: @query_start,
				query_end: @query_end
			}
	    fetcher = Fetcher::Histories.new([ticker], options)
	    history_hashes = fetcher.fetch
	    History.insert_or_update(history_hashes)
	  end

	end
end