class StockQuoteUpdater

	def initialize(stocks)
		yahoo_api_quotes(Stock.all)
	end

	private
	def yahoo_api_quotes(stocks)
		# limit of BATCHLIMIT_QUOTES per api call
		yahoo_tickers =  stocks.map {|x| "'" + x.ticker + "'"}.join(', ')
		url = 'https://query.yahooapis.com/v1/public/yql?q='
		url += URI.encode("SELECT * FROM yahoo.finance.quotes WHERE symbol IN (#{yahoo_tickers})")
		url += '&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback='
		data = open(url, {:read_timeout=>3}).read
		parse_quote_data(data)
	end

	def parse_quote_data(data)
		data = JSON.parse(data)
		ActiveRecord::Base.transaction do
			data["query"]["results"]["quote"].each do |stock_hash|
				Rails.logger.info "this value? #{stock_hash}"
				update_stock(stock_hash)
			end
		end
	end

	def update_stock(stock_hash)
		stock = Stock.where(ticker: stock_hash["symbol"]).first
		stock.update(
			name: stock_hash["Name"],
			last_price: BigDecimal.new(stock_hash["LastTradePriceOnly"]),
			last_trade: parse_last_trade_time(stock_hash),
			stock_exchange: stock_hash["StockExchange"])
	end

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