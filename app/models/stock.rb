class Stock < ActiveRecord::Base
	include YahooFinance

	def self.test_2
		puts "test_21"
	end


	def self.today_prices
		url = 'https://query.yahooapis.com/v1/public/yql?q='
		url += URI.encode("SELECT * FROM yahoo.finance.quotes WHERE symbol IN ('ZZZ.TO','RSY.V')")
		url += '&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback='
		data = open(url, {:read_timeout=>3}).read
		parse_today_data(data)
	end

	def self.moving_day_avg(stocks)
		moving_averages = {}
		stocks.each do |stock|
			hist = HistoricalPrice.where(ticker: stock.ticker).order(date: :asc)
			Rails.logger.info "hist.count: #{hist.count}"
			if hist.count > 0
				days_20 = calc_avg(hist, 20)
				days_50 = calc_avg(hist, 50)
				moving_averages.merge!(:"#{stock.ticker}" => [days_20, days_50])
			else 
				days_20 = "n/a"
				days_50 = "n/a"
				moving_averages.merge!(:"#{stock.ticker}" => [days_20, days_50])
			end
			Rails.logger.info "moving_averages: #{moving_averages}"
		end
		return moving_averages
	end

	private

	def self.calc_avg(hist, days)
		Rails.logger.info "hist2: #{hist}"
		std_arr = []
		hist_p  = hist[hist.count-days..hist.count-1].map {|x| x.price}
		0.upto(hist_p.count-1) {|x| std_arr << [(hist_p.count+1-x).days.ago, (hist_p[0..x].sum/100.00)/(x+1)]}
		# hist[hist.count-days..hist.count-1].sum{|x| x.price}/100.00/(days/1.00)
		return std_arr[std_arr.count-20..std_arr.count-1]
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
				last_price: stock_hash["LastTradePriceOnly"].to_i*100)
		else
			stock.update(
				ticker: stock_hash["symbol"],
				name: stock_hash["Name"],
				last_price: stock_hash["LastTradePriceOnly"].to_i*100)
		end
	end
end
