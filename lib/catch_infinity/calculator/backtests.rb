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
			@query_start = options[:query_start] || 1.year.ago.strftime("%Y-%m-%d")
			@query_end = options[:query_end] || Time.now.strftime("%Y-%m-%d")
			@value_start = options[:value_start]
			@dollar_cost_average = options[:dollar_cost_average]
			@sell_signal = options[:sell_signal]
			@buy_signal = options[:buy_signal]
			@stocks = options[:stocks]
		end

		def calculate
			# guard_clauses
			check_and_fetch_missing_histories
			# grind_numbers
			puts "STOCKS: #{@stocks}"
			return {}
		end

		private

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