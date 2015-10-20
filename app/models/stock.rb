require_relative '../../lib/catch_infinity/fetcher/stocks'
require_relative '../../lib/catch_infinity/fetcher/histories'

class Stock < ActiveRecord::Base
	has_many :histories
	has_many :backtest_stocks
	has_many :backtests, through: :backtest_stocks

	validates :ticker, uniqueness: true , length: { minimum: 1 }
	validates :name, presence: true

	def self.insert_or_update(stock_hashes)
	  begin
	    Stock.transaction do
	    	stock_hashes.each do |stock_hash|
	    		if stock = Stock.where(ticker: stock_hash[:ticker]).first
	    			stock.update!(stock_hash)
	    		else
	    			Stock.create!(stock_hash)
	    		end
	    	end
	    end
	  rescue => e
	    Rails.logger.info("There was an exception: #{e}")
	  end
	end

	private
end
