class StockHistoryFetcher
	attr_reader :stocks, :query_start, :query_end

	def initialize(stocks_array)
		@stocks = stocks_array
		@query_end = Time.now.strftime("%Y-%m-%d")
		@query_start = 3.months.ago.strftime("%Y-%m-%d")
	end

	def fetch
		prices = call_api
	end

	private

	def call_api
		history_hash = Hash.new(0)
		@stocks.each do |stock|
			add_stock_to_hash(stock, history_hash)
		end
		return history_hash
	end

	def add_stock_to_hash(stock, history_hash)
			url = yahoo_history_url(stock)
			message = open(url, {:read_timeout=>3}).read
			history_hash.merge!(parse_stock_timeseries(message))
	end

	def yahoo_history_url(stock)
		url = 'https://query.yahooapis.com/v1/public/yql?q='
		url += URI.encode(%Q(select * from yahoo.finance.historicaldata where symbol = "#{stock.ticker}" and startDate = "#{@query_start}" and endDate = "#{@query_end}"))
		url += '&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback='
	end

	def parse_stock_timeseries(message)
		data = JSON.parse(message)["query"]["results"]["quote"]	
		stock_hash = hash_stock_timeseries(data)
		stock_series = { data.first["Symbol"] => stock_hash}
		return stock_series
	end	

	def hash_stock_timeseries(data)
		stock_hash = Hash.new(0)
		data.each do |days_info|
			date = parse_year_month_day(days_info)
			stock_hash[date] = {
				price_day_close: BigDecimal.new("#{days_info["High"]}"),
			}
		end
		return stock_hash
	end

	def parse_year_month_day(days_info)
		date_ymd = days_info["Date"].split('-').map {|x| x.to_i}
		DateTime.new(date_ymd[0],date_ymd[1],date_ymd[2])
	end
end