module StocksHelper
	def moving_day_avg(stock, days)
		return days*10
	end

	def to_price(price)
		return '%.2f' % (price.to_f/100)
	end

	def chartkick_format(date, values)
		formatted = {}
		0.upto(date.count-1) {|x| formatted.merge!(date[x] => values[x])}
		return formatted
	end
end
