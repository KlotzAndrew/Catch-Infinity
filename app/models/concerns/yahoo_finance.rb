module Sortinghat
	extend ActiveSupport::Concern

	def self.update_history(base_time = 3.months.ago)
		base_time = 3.months.ago
		query_start = base_time.strftime("%Y-%m-%d")
		query_end = Time.now.strftime("%Y-%m-%d")
		stock = "YHOO"
		url = 'https://query.yahooapis.com/v1/public/yql?q='
		url += URI.encode(%Q(select * from yahoo.finance.historicaldata where symbol = "#{stock}" and startDate = "#{query_start}" and endDate = "#{query_end}"))
		url += '&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback='
		data = open(url, {:read_timeout=>3}).read
				parse_historical_data(data)
	end
end