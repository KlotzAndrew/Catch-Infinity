class StockHistoryFetcher
	attr_reader :stocks

	def initialize(stocks_array)
		@stocks = stocks_array
	end

	def fetch
		prices = historical_api
	end

	private

	def historical_api
		base_time = 3.months.ago
		query_start = base_time.strftime("%Y-%m-%d")
		history_hash = Hash.new(0)
		query_end = Time.now.strftime("%Y-%m-%d")
		@stocks.each do |stock|
			url = 'https://query.yahooapis.com/v1/public/yql?q='
			url += URI.encode(%Q(select * from yahoo.finance.historicaldata where symbol = "#{stock.ticker}" and startDate = "#{query_start}" and endDate = "#{query_end}"))
			url += '&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback='
			data = open(url, {:read_timeout=>3}).read
			history_hash.merge!(parse_stock_history(data))
		end
		return history_hash
	end

	def parse_stock_history(data)
		data = JSON.parse(data)
		price_data = data["query"]["results"]["quote"]
		# stock_hash[price_data["Symbol"]] = {}
		
		stock_hash = Hash.new(0)
		data["query"]["results"]["quote"].each do |days_info|
			date_ymd = days_info["Date"].split('-').map {|x| x.to_i}
			date = DateTime.new(date_ymd[0],date_ymd[1],date_ymd[2])
			stock_hash[date] = {
				price_day_close: BigDecimal.new("#{days_info["High"]}"),
			}

		end
		h1 = { price_data.first["Symbol"] => stock_hash}
		return h1
	end	
end