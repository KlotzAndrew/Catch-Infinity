class StockQuoteFetcher
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
		url = yahoo_quote_url(yahoo_tickers)
		message = open(url, {:read_timeout=>3}).read
		parse_quote_data(message)
	end

	def yahoo_quote_url(yahoo_tickers)
		url = 'https://query.yahooapis.com/v1/public/yql?q='
		url += URI.encode("SELECT * FROM yahoo.finance.quotes WHERE symbol IN (#{yahoo_tickers})")
		url += '&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback='
	end

	def parse_quote_data(message)
		data = JSON.parse(message)
		price_hash = Hash.new(0)
		data["query"]["results"]["quote"].each do |stock_hash|
			combine_price_hashes(price_hash, stock_hash)
		end
		return price_hash
	end

	def combine_price_hashes(price_hash, stock_hash)
		price_hash[stock_hash["symbol"]] = 
			{
				name: stock_hash["Name"],
				last_price: BigDecimal.new(stock_hash["LastTradePriceOnly"]),
				last_trade: parse_last_trade_time(stock_hash),
				stock_exchange: stock_hash["StockExchange"]
			}
	end

	def parse_last_trade_time(stock_hash)
		mdy = parse_month_day_year(stock_hash)
		hrs_mins = parse_hrs_mins(stock_hash)
		DateTime.new(mdy[2],mdy[0],mdy[1],hrs_mins[0],hrs_mins[1])
	end	

	def parse_month_day_year(stock_hash)
		stock_hash["LastTradeDate"].split('/').map {|x| x.to_i}
	end

	def parse_hrs_mins(stock_hash)
		clock12hr = stock_hash["LastTradeWithTime"].split.first
		am_or_pm = clock12hr[clock12hr.length-2..clock12hr.length-1]
		hrs_mins = clock12hr[0..clock12hr.length-3].split(':').map {|x| x.to_i}
		hrs_mins[0] += 12 if am_or_pm == "pm" && hrs_mins[0] < 12
		return hrs_mins
	end


end