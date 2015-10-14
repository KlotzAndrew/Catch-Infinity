require_relative '../../lib/catch_infinity/stock_quote_fetcher'
require_relative '../../lib/catch_infinity/stock_history_fetcher'

class Stock < ActiveRecord::Base
	has_many :HistoricalPrices
	validates :ticker, uniqueness: true
	BATCHLIMIT_QUOTES = 400

	def self.all_prices
		index_hash = {}
		Stock.all.each do |stock|
			index_hash.merge!(
				stock.ticker => {
					stock: stock,
					prices: calculate_trends(stock.HistoricalPrices.order(date: :asc))
				}
			)
		end
		return index_hash
	end

	def self.current_price(stocks_array = Stock.all)
		fetcher = StockQuoteFetcher.new(stocks_array)
		update_prices(fetcher.fetch)
	end

	def self.past_prices(stocks_array = Stock.all)
		fetcher = StockHistoryFetcher.new(stocks_array)
		update_histories(fetcher.fetch)
	end	

	private
	
	def self.update_histories(prices)
		prices.each_pair do |ticker, values|
			save_price_points(ticker, values)
		end
	end

	def self.save_price_points(ticker, values)
		stock = Stock.where(ticker: ticker).first
		values.each_pair do |date, data|
			historicalprice = stock.HistoricalPrices.where(date: date).first
			if historicalprice.nil?
				HistoricalPrice.create(
					price_day_close: data[:price_day_close],
					date: date,
					stock_id: stock.id)
			end
		end			
	end

	def self.update_prices(prices)
		begin
			Stock.transaction do
				prices.each_pair do |ticker, values|
					stock = Stock.where(ticker: ticker).first
					if stock.nil?
						raise "no stock found!" if values[:name].nil?
						stock = Stock.create(
							ticker: ticker,
							name: values[:name],
							last_price: values[:last_price],
							last_trade: values[:last_trade],
							stock_exchange: values[:stock_exchange])
						past_prices([stock])
						# create_if_valid(ticker, values)
					else
						stock.update!(
							name: values[:name],
							last_price: values[:last_price],
							last_trade: values[:last_trade],
							stock_exchange: values[:stock_exchange])
					end
				end
			end
		rescue => e
			# Rails.logger("Tell me about this exception #{e.message}")
		end
	end

	def create_if_valid(ticker, values)
		puts "TICKER2: #{ticker}"
		puts "NEWSTOCK: #{stock.inspect}"
	end

	def self.calculate_trends(historicalprices)
		return nil if historicalprices.count < 50
		chart_hash = {
			raw_prices: chart_raw_prices(historicalprices),
			avg_50_days: chart_day_avg(historicalprices, 50),
			avg_20_days: chart_day_avg(historicalprices, 20)
		}
	end

	def self.chart_day_avg(historicalprices, range)
		avg_price_hash, moving_total, moving_count = {}, BigDecimal.new(0), BigDecimal.new(0)
		(historicalprices.count-range).upto(historicalprices.count-1) do |x|
			moving_total += historicalprices[x].price_day_close
			moving_count += 1
			avg_price_hash.merge!(historicalprices[x].date => (moving_total/moving_count).to_f)
		end
		return avg_price_hash
	end

	def self.chart_raw_prices(historicalprices)
		raw_prices_hash = {}
		historicalprices[historicalprices.count-50..historicalprices.count-1].each do |x|
			raw_prices_hash.merge!(x.date => x.price_day_close.to_f)
		end
		add_current_price(historicalprices.first.stock, raw_prices_hash)
		return raw_prices_hash
	end

	def self.add_current_price(stock, price_hash)
		price_hash.merge!(stock.last_trade => stock.last_price.to_f)
	end
end
