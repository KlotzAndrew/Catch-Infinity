class StockQuoteUpdater
	attr_reader :stocks
	BATCHLIMIT_QUOTES = 400

	def initialize(stocks_array)
		@stocks = stocks_array
	end

	def fetch
		quotes = call_api
	end

	private

	def call_api
		# limit of BATCHLIMIT_QUOTES per api call
		yahoo_tickers =  @stocks.map {|x| "'" + x.ticker + "'"}.join(', ')
		url = 'https://query.yahooapis.com/v1/public/yql?q='
		url += URI.encode("SELECT * FROM yahoo.finance.quotes WHERE symbol IN (#{yahoo_tickers})")
		url += '&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback='
		message = open(url, {:read_timeout=>3}).read
		parse_quote_data(message)
	end

	def parse_quote_data(message)
		data = JSON.parse(message)
		price_hash = Hash.new(0)
		data["query"]["results"]["quote"].each do |stock_hash|
			price_hash[stock_hash["symbol"]] = 
				{
					name: stock_hash["Name"],
					last_price: BigDecimal.new(stock_hash["LastTradePriceOnly"]),
					last_trade: parse_last_trade_time(stock_hash),
					stock_exchange: stock_hash["StockExchange"]
				}
		end
		return price_hash
	end



	# def update_stock(stock_hash)
	# 	stock = Stock.where(ticker: stock_hash["symbol"]).first
	# 	stock.update(
	# 		name: stock_hash["Name"],
	# 		last_price: BigDecimal.new(stock_hash["LastTradePriceOnly"]),
	# 		last_trade: parse_last_trade_time(stock_hash),
	# 		stock_exchange: stock_hash["StockExchange"])
	# end

	def parse_last_trade_time(stock_hash)
		wt = stock_hash["LastTradeDate"].split('/').map {|x| x.to_i}
		dt = stock_hash["LastTradeWithTime"].split.first
		pm = dt[dt.length-2..dt.length-1]
		ht = dt[0..dt.length-3].split(':').map {|x| x.to_i}
		ht[0] += 12 if pm == "pm" && ht[0] < 12
		et = "#{wt[2]},#{wt[0]},#{wt[1]},#{ht[0]},#{ht[1]}"
		DateTime.new(wt[2],wt[0],wt[1],ht[0],ht[1])
	end	

end