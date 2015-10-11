class Stock < ActiveRecord::Base
	has_many :HistoricalPrices
	validates :ticker, uniqueness: true
	BATCHLIMIT_QUOTES = 400

	def self.current_price
		yahoo_api_quotes(Stock.all)
	end

	def self.historical_price(options = {})
		base_time = options[:start] || 3.months.ago
		query_start = base_time.strftime("%Y-%m-%d")
		yahoo_api_historical(Stock.all, query_start)
	end

	private

	def self.yahoo_api_historical(stocks, query_start)
		query_end = Time.now.strftime("%Y-%m-%d")
		stocks.each do |stock|
			Rails.logger.info "stock_obj: #{stock.ticker}"
			url = 'https://query.yahooapis.com/v1/public/yql?q='
			url += URI.encode(%Q(select * from yahoo.finance.historicaldata where symbol = "#{stock.ticker}" and startDate = "#{query_start}" and endDate = "#{query_end}"))
			url += '&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback='
			data = open(url, {:read_timeout=>3}).read
			update_stock_history(data)
		end
	end

	def self.update_stock_history(data)
		data = JSON.parse(data)
		ActiveRecord::Base.transaction do
			data["query"]["results"]["quote"].each do |days_info|
				date_ymd = days_info["Date"].split('-').map {|x| x.to_i}
				date = DateTime.new(date_ymd[0],date_ymd[1],date_ymd[2])
				stock = Stock.where(ticker: days_info["Symbol"]).first
				historicalprice = stock.HistoricalPrices.where(date: date).first
				if historicalprice.nil?
					HistoricalPrice.create(
						price_day_close: days_info["High"],
						date: date,
						stock_id: stock.id)
				end
			end
		end
	end

	def self.yahoo_api_quotes(stocks)
		# limit of BATCHLIMIT_QUOTES per api call
		yahoo_tickers =  stocks.map {|x| "'" + x.ticker + "'"}.join(', ')
		url = 'https://query.yahooapis.com/v1/public/yql?q='
		url += URI.encode("SELECT * FROM yahoo.finance.quotes WHERE symbol IN (#{yahoo_tickers})")
		url += '&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback='
		data = open(url, {:read_timeout=>3}).read
		parse_quote_data(data)
	end

	def self.parse_quote_data(data)
		data = JSON.parse(data)
		ActiveRecord::Base.transaction do
			data["query"]["results"]["quote"].each do |stock_hash|
				Rails.logger.info "this value? #{stock_hash}"
				update_stock(stock_hash)
			end
		end
	end

	def self.update_stock(stock_hash)
		stock = Stock.where(ticker: stock_hash["symbol"]).first
		stock.update(
			name: stock_hash["Name"],
			last_price: BigDecimal.new(stock_hash["LastTradePriceOnly"]),
			last_trade: parse_last_trade_time(stock_hash),
			stock_exchange: stock_hash["StockExchange"])
	end

	def self.parse_last_trade_time(stock_hash)
		wt = stock_hash["LastTradeDate"].split('/').map {|x| x.to_i}
		dt = stock_hash["LastTradeWithTime"].split.first
		pm = dt[dt.length-2..dt.length-1]
		ht = dt[0..dt.length-3].split(':').map {|x| x.to_i}
		ht[0] += 12 if pm == "pm" && ht[0] < 12
		et = "#{wt[2]},#{wt[0]},#{wt[1]},#{ht[0]},#{ht[1]}"
		DateTime.new(wt[2],wt[0],wt[1],ht[0],ht[1])
	end
end
