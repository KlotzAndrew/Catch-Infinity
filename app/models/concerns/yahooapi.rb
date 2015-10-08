module Yahooapi
	extend ActiveSupport::Concern

	#this needs to be scalable for all tickers (either as subclass or module)

	def self.fetch_history(base_time = 3.months.ago)
		# base_time = 3.months.ago
		query_start = base_time.strftime("%Y-%m-%d")
		query_end = Time.now.strftime("%Y-%m-%d")
		all_tickers.each do |stock|
			Rails.logger.info "stock_obj: #{stock}"
			url = 'https://query.yahooapis.com/v1/public/yql?q='
			url += URI.encode(%Q(select * from yahoo.finance.historicaldata where symbol = "#{stock}" and startDate = "#{query_start}" and endDate = "#{query_end}"))
			url += '&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback='
			data = open(url, {:read_timeout=>3}).read
			save_history(data)
		end
	end

	def self.fetch_today
		api_batches = all_tickers.each_slice(400).to_a
		api_batches.each {|x| Stock.update_current_price(x)}
	end


	def self.all_tickers
		#has to return yahoo formatted tickers
		hide_these = %w{ id record_date created_at updated_at }
		ticker_hash = self.new.attributes.reject {|key| hide_these.include?(key)}
		tickers = ticker_hash.map {|key, value| key.gsub('_', '.')}
		# return tickers[450..452]
	end

	def self.only_upward_trends
		last_50_days = self.order(record_date: :desc)[0..49].reverse
		ticker_hash = build_running_averages(last_50_days)
		return ticker_hash
	end

	private

	def self.build_running_averages(data_range)
		ticker_hash = {}
		all_tickers.map {|key| key.gsub('.', '_')}.each do |ticker|
			valid_dates = data_range.select {|x| x if x[ticker]}
			prices_50 = valid_dates.map {|day| day[ticker]}
			prices_20 = prices_50[prices_50.count-20..prices_50.count-1]
			dates = valid_dates.map {|day| day.record_date }

			all_avg_50 = []
			0.upto(prices_50.count-1) {|x| all_avg_50 << (prices_50[0..x].sum)/(x+1)}
			all_avg_20 = []
			0.upto(prices_20.count-1) {|x| all_avg_20 << (prices_20[0..x].sum)/(x+1)}

			current_stock = Stock.where(ticker: ticker.gsub('_', '.')).first
			if prices_20.last > all_avg_50.last && prices_20.last > all_avg_20.last
				ticker_hash.merge!(ticker.to_sym => {
					raw_prices: prices_20,
					avg_50_days: all_avg_50[all_avg_50.count-20..all_avg_50.count-1],
					avg_20_days: all_avg_20,
					dates:  dates[dates.count-20..dates.count-1],
					current_value: current_stock
				}
				)
			end
		end
		return ticker_hash
	end

	def self.save_history(data)
		data = JSON.parse(data)
		ActiveRecord::Base.transaction do
			data["query"]["results"]["quote"].each do |days_info|
				date_ymd = days_info["Date"].split('-').map {|x| x.to_i}
				date = DateTime.new(date_ymd[0],date_ymd[1],date_ymd[2])
				table_record = get_table_record(date)
				stock = days_info["Symbol"].gsub('.', '_')
				if table_record[stock].nil?
					table_record.update(stock.to_sym => days_info["High"].to_f)
				end
			end
		end
	end

	def self.get_table_record(date)
		record = self.where(record_date: date).first
		if record.nil?
			record = self.create(record_date: date)
		end
		return record
	end
end
