module Builder
	class Charts
		attr_reader :stocks

		def initialize(stock_array)
			@stocks = stock_array
		end

		def format_for_google
			merge_stock_series
		end

		def merge_stock_series
			index_hash = {}
			@stocks.each do |stock|
				index_hash.merge!(
					stock.ticker => {
						stock: stock,
						prices: calculate_trends(stock.histories.order(date: :asc))
					}
				)
			end
			index_hash = sort_by_breakout_value(index_hash) if index_hash.count > 1
			return index_hash
		end

		def calculate_trends(historicalprices)
			return nil if historicalprices.count < 50
			chart_hash = {
				raw_prices: chart_raw_prices(historicalprices),
				avg_50_days: chart_day_avg(historicalprices, 50),
				avg_20_days: chart_day_avg(historicalprices, 20),
			}
			return add_breakout_value(chart_hash)
		end

		def add_breakout_value(chart_hash)
			chart_hash[:today_jump] = (chart_hash[:raw_prices].values.last - chart_hash[:avg_20_days].values.last)
			return chart_hash
		end

		def sort_by_breakout_value(index_hash)
			hash = index_hash.sort { |a,v| (a[1][:prices].nil? or v[1][:prices].nil?) ? ( a ? -1 : 1 ) : v[1][:prices][:today_jump] <=> a[1][:prices][:today_jump] }
			return hash
		end

		def chart_day_avg(historicalprices, range)
			avg_price_hash, moving_total, moving_count = {}, BigDecimal.new(0), BigDecimal.new(0)
			(historicalprices.count-range).upto(historicalprices.count-1) do |x|
				moving_total += historicalprices[x].price_day_close
				moving_count += 1
				avg_price_hash.merge!(historicalprices[x].date => (moving_total/moving_count).to_f)
			end
			return avg_price_hash
		end

		def chart_raw_prices(historicalprices)
			raw_prices_hash = {}
			historicalprices[historicalprices.count-50..historicalprices.count-1].each do |x|
				raw_prices_hash.merge!(x.date => x.price_day_close.to_f)
			end
			add_current_price(historicalprices.first.stock, raw_prices_hash)
			return raw_prices_hash
		end

		def add_current_price(stock, price_hash)
			price_hash.merge!(stock.last_trade => stock.last_price.to_f)
		end
	end
end