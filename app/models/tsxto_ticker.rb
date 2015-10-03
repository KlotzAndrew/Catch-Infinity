class TsxtoTicker < ActiveRecord::Base
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

	def self.all_tickers(yahoo_format = true)
		remove_these = %w{ id record_date created_at updated_at }
		ticker_hash = self.new.attributes.reject {|key| remove_these.include?(key)}
		ticker_hash.map {|key, value| key.gsub('_', '.')}
	end

	def self.only_upward_trends
		ticker_hash = {}
		last_50_days = self.order(record_date: :desc)[0..49]
		dates = last_50_days[0..19].map {|x| x.record_date}
		all_tickers.map {|key| key.gsub('.', '_')}.each do |ticker|
			#pull ticker prices into array of 50
			all_50_day_prices = []
			0.upto(last_50_days.count-1) do |day| 
				if last_50_days[day][ticker].nil?
					all_50_day_prices << 0 #this is bad
				else
					all_50_day_prices << last_50_days[day][ticker]
				end
			end
			all_avg_50 = []
			0.upto(49) {|x| all_avg_50 << (all_50_day_prices.reverse[0..x].sum)/(x+1)}
			all_avg_20 = []
			0.upto(19) {|x| all_avg_20 << (all_50_day_prices[0..19].reverse[0..x].sum)/(x+1)}

			# raw_prices = {raw_prices: all_50_day_prices}
			# avg_50_days = {avg_50_days: all_avg_50}
			# avg_20_days = {avg_20_days: all_avg_20}


			ticker_hash.merge!({ticker => {
				raw_prices: all_50_day_prices[0..19],
				avg_50_days: all_avg_50[0..19],
				avg_20_days: all_avg_20 }
			})
		end
		return {dates: dates, values: ticker_hash}
	end

	private

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
