class Stock < ActiveRecord::Base

	def self.today_prices
		url = 'https://query.yahooapis.com/v1/public/yql?q='
		url += URI.encode("SELECT * FROM yahoo.finance.quotes WHERE symbol IN ('YHOO','AAPL','GOOG','MSFT')")
		url += '&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback='
		data = open(url, {:read_timeout=>3}).read
		parse_today_data(data)
	end

	def self.get_history
		url = 'https://query.yahooapis.com/v1/public/yql?q='
		url += URI.encode("select * from yahoo.finance.historicaldata where symbol = 'YHOO' and startDate = '2015-29-07' and endDate = '2015-29-09'")
		url += '&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback='
		data = open(url, {:read_timeout=>3}).read
		parse_historical_data(data)
	end

	private

	def self.parse_historical_data(data)
		data = JSON.parse(data)
		data["query"]["results"]["quote"].each do |stock_hash|
			date_raw = stock_hash["Date"]
			date = (date_raw[0..3] + date_raw[8..9] + date_raw[5..6]).to_i
			history = HistoricalPrice.where(ticker: stock_hash["Symbol"]).where(date: date).first
			if history.nil?
				HistoricalPrice.create(
					ticker: stock_hash["Symbol"],
					date: date,
					price: stock_hash["Close"])
			end
		end
	end

	def self.parse_today_data(data)
		data = JSON.parse(data)
		data["query"]["results"]["quote"].each do |stock_hash|
			find_or_create(stock_hash)
		end
	end

	def self.find_or_create(stock_hash)
		stock = Stock.where(ticker: stock_hash["symbol"]).first
		if stock.nil?
			Stock.create(
				ticker: stock_hash["symbol"],
				name: stock_hash["Name"],
				last_price: ["LastTradePriceOnly"].to_i*100)
		else
			stock.update(
				ticker: stock_hash["symbol"],
				name: stock_hash["Name"],
				last_price: stock_hash["LastTradePriceOnly"].to_i*100)
		end
	end
end
