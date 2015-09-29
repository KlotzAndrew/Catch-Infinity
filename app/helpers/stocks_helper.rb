module StocksHelper
	def moving_day_avg(stock, days)
		return days*10
	end

	def to_price(price)
		return '%.2f' % (price.to_f/100)
	end
end
