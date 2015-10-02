class TsxtoTicker < ActiveRecord::Base
	#this needs to be scalable for all tickers (either as subclass or module)

	def self.update_history(base_time = 3.months.ago)
		base_time = 3.months.ago
		query_start = base_time.strftime("%Y-%m-%d")
		query_end = Time.now.strftime("%Y-%m-%d")
		all_tickers.each do |stock|
			url = 'https://query.yahooapis.com/v1/public/yql?q='
			url += URI.encode(%Q(select * from yahoo.finance.historicaldata where symbol = "#{stock}" and startDate = "#{query_start}" and endDate = "#{query_end}"))
			url += '&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback='
			data = open(url, {:read_timeout=>3}).read
		end
		# stock = "AAB.TO"
		# parse_historical_data(data)
	end

	def self.all_tickers
		remove_these = %w{ id record_date created_at updated_at }
		ticker_hash = self.new.attributes.reject {|key| remove_these.include?(key)}
		ticker_hash.map {|key, value| key[1..key.length-1].gsub('_', '.')}
	end

	def self.h1
		puts all_tickers

	end

	private

end
