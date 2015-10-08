class Stock < ActiveRecord::Base
	validates :ticker, uniqueness: true

	#will update all stocks
	def self.current_price
		prepare_tickers
	end

	def self.historical_price
		#hit yahoo historical api
	end

	private

	def self.prepare_tickers
		build_ticker_array
	end

	def self.build_ticker_array
	end
end
