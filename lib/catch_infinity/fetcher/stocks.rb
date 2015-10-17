module Fetcher
	class Stocks
		attr_reader :tickers
		BATCHLIMIT_QUOTES = 400

		def initialize(ticker_array)
			@tickers = ticker_array
		end

		def fetch
			send_tickers_to_api
		end

		private

		def send_tickers_to_api
			# limit of BATCHLIMIT_QUOTES per api call
			yahoo_tickers = tickers_yahoo_format
			return nil unless yahoo_tickers.length > 0
			request_and_collect_api(yahoo_tickers)
		end

		def request_and_collect_api(yahoo_tickers)
			url = yahoo_quote_url(yahoo_tickers)
			message = open(url, {:read_timeout=>3}).read
			parse_quote_data(message)
		end

		def tickers_yahoo_format
			valid_stocks = @tickers.select {|x| x if x.length > 0 }
			valid_stocks.map {|x| "'" + x + "'"}.join(', ')
		end

		def yahoo_quote_url(yahoo_tickers)
			url = 'https://query.yahooapis.com/v1/public/yql?q='
			url += URI.encode("SELECT * FROM yahoo.finance.quotes WHERE symbol IN (#{yahoo_tickers})")
			url += '&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback='
		end

		def parse_quote_data(message)
			data = JSON.parse(message)
			stocks_array = []
			if data["query"]["results"]["quote"].class == Hash
				stock_hash = data["query"]["results"]["quote"]
				hash = combine_price_hashes(stock_hash)
				stocks_array << hash unless hash.nil?
			else
				data["query"]["results"]["quote"].each do |stock_hash|
					hash = combine_price_hashes(stock_hash)
					stocks_array << hash unless hash.nil?
				end
			end
			return stocks_array
		end

		def combine_price_hashes(stock_hash)
			if stock_hash["Name"].nil?
					nil
			else
					{
						ticker: stock_hash["symbol"],
						name: stock_hash["Name"],
						last_price: BigDecimal.new(stock_hash["LastTradePriceOnly"]),
						last_trade: parse_last_trade_time(stock_hash),
						stock_exchange: stock_hash["StockExchange"]
					}
			end
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
end