class Stock < ActiveRecord::Base
	def self.today_prices
		url = 'https://query.yahooapis.com/v1/public/yql?q='
		url += URI.encode("SELECT * FROM yahoo.finance.quotes WHERE symbol IN ('ZZZ.TO','RSY.V')")
		url += '&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback='
		data = open(url, {:read_timeout=>3}).read
		parse_today_data(data)
	end

	private
	def self.update_current_price(tickers)
		yahoo_tickers = tickers.map {|x| "'" + x + "'"}.join(', ')
		if yahoo_tickers.count > 0
			url = 'https://query.yahooapis.com/v1/public/yql?q='
			url += URI.encode("SELECT * FROM yahoo.finance.quotes WHERE symbol IN (#{yahoo_tickers})")
			url += '&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback='
			data = open(url, {:read_timeout=>3}).read
			parse_today_data(data)
		end
	end

	def self.parse_today_data(data)
		data = JSON.parse(data)
		ActiveRecord::Base.transaction do
			data["query"]["results"]["quote"].each do |stock_hash|
				Rails.logger.info "this value? #{stock_hash}"
				find_or_create(stock_hash)
			end
		end
	end

	def self.find_or_create(stock_hash)
		stock = Stock.where(ticker: stock_hash["symbol"]).first
		last_trade = format_silly_time(stock_hash)
		if stock.nil?
			Stock.create(
				ticker: stock_hash["symbol"],
				name: stock_hash["Name"],
				last_price: stock_hash["LastTradePriceOnly"].to_f*100,
				last_trade: last_trade)
		else
			stock.update(
				ticker: stock_hash["symbol"],
				name: stock_hash["Name"],
				last_price: stock_hash["LastTradePriceOnly"].to_f*100,
				last_trade: last_trade)
		end
	end

	def self.format_silly_time(stock_hash)
		wt = stock_hash["LastTradeDate"].split('/').map {|x| x.to_i}
		dt = stock_hash["LastTradeWithTime"].split.first
		pm = dt[dt.length-2..dt.length-1]
		ht = dt[0..dt.length-3].split(':').map {|x| x.to_i}
		ht[0] += 12 if pm == "pm" && ht[0] < 12
		et = "#{wt[2]},#{wt[0]},#{wt[1]},#{ht[0]},#{ht[1]}"
		Rails.logger.info "date_[LastTradeDate]: #{wt}"
		Rails.logger.info "date_[LastTradeWithTime #{dt}"
		Rails.logger.info "wt[2],wt[0],wt[1],ht[0],ht[1]: #{et}"
		return DateTime.new(wt[2],wt[0],wt[1],ht[0],ht[1])
	end
end
