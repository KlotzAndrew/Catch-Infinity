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
		# stock = "AAB.TO"
		# parse_historical_data(data)
	end

	def self.all_tickers
		remove_these = %w{ id record_date created_at updated_at }
		ticker_hash = self.new.attributes.reject {|key| remove_these.include?(key)}
		ticker_hash.map {|key, value| key.gsub('_', '.')}
	end

	def self.h1
		puts self.new.inspect
	end

	private

	def self.save_history(data)
		data = JSON.parse(data)
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

	def self.get_table_record(date)
		record = self.where(record_date: date).first
		if record.nil?
			record = self.create(record_date: date)
		end
		return record
	end

end
