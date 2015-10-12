module StocksHelper
	def moving_day_avg(stock, days)
		return days*10
	end

	def to_price(price)
		return '%.2f' % (price.to_f/100)
	end

	def chartkick_format(input_data, query)
		formatted = {}
		tot_values = input_data[query.to_sym].count
		0.upto(tot_values-1) {|x| formatted.merge!(input_data[:dates][x] => input_data[query.to_sym][x].to_f)}
		if query == "raw_prices"
			stock = input_data[:current_value]
			Rails.logger.info "STOCK: #{stock.last_trade}"
			Rails.logger.info "STOCK: #{stock.last_price/100.00}"
			formatted.merge!(stock.last_trade => (stock.last_price/100.00))
		end
		return formatted
	end

	def last_price(stock)
		value = stock[:current_value].last_price/100.00
		return "last value missing" if value == 0
		value
	end

	def chart_yrange(values_hash)
		prices = values_hash.map {|x,y| y}
		(prices.min.to_i)..(prices.max.to_i)
	end
end
