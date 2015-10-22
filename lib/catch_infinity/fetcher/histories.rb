module Fetcher
	class Histories
		attr_reader :tickers, :query_start, :query_end

		def initialize(ticker_array, options = {})
			@tickers = ticker_array
			@query_end = options[:query_start] || Time.now
			@query_start = options[:query_end] || 3.months.ago
			@query_end = @query_end.strftime("%Y-%m-%d")
			@query_start = @query_start.strftime("%Y-%m-%d")
		end

		def fetch
			send_tickers_to_api
		end

		private

		def send_tickers_to_api
			history_hash = Hash.new(0)
			@tickers.each do |ticker|
				add_stock_to_hash(ticker, history_hash)
			end
			return history_hash
		end

		def add_stock_to_hash(ticker, history_hash)
				url = yahoo_history_url(ticker)
				message = open(url, {:read_timeout=>3}).read
				history_hash.merge!(parse_stock_timeseries(message))
		end

		def yahoo_history_url(ticker)
			url = 'https://query.yahooapis.com/v1/public/yql?q='
			url += URI.encode(%Q(select * from yahoo.finance.historicaldata where symbol = "#{ticker}" and startDate = "#{@query_start}" and endDate = "#{@query_end}"))
			url += '&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback='
		end

		def parse_stock_timeseries(message)
			json = JSON.parse(message)
			data = json["query"]["results"]["quote"] unless json["query"]["http-status-code"] == "404"
			stock_hash = hash_stock_timeseries(data)
			stock_series = { data.first["Symbol"] => stock_hash}
			return stock_series
		end	

		def hash_stock_timeseries(data)
			stock_array = []
			data.each do |days_info|
				date = parse_year_month_day(days_info)
				stock_array << {
					date: date,
					price_day_close: BigDecimal.new("#{days_info["High"]}"),
				}
			end
			return stock_array
		end

		def parse_year_month_day(days_info)
			date_ymd = days_info["Date"].split('-').map {|x| x.to_i}
			DateTime.new(date_ymd[0],date_ymd[1],date_ymd[2])
		end
	end
end