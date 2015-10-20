module Calculator
	class Backtests
		attr_reader :query_start
		attr_reader :query_end
		attr_reader :value_start
		attr_reader :dollar_cost_average
		attr_reader :sell_signal
		attr_reader :buy_signal


		def initialize(options = {})
			@query_start = options[:query_start] || 1.year.ago.strftime("%Y-%m-%d")
			@query_end = options[:query_end] || Time.now.strftime("%Y-%m-%d")
			@value_start = options[:value_start]
			@dollar_cost_average = options[:dollar_cost_average]
			@sell_signal = options[:sell_signal]
			@buy_signal = options[:buy_signal]
		end

		def calculate
			return {}
		end
	end
end