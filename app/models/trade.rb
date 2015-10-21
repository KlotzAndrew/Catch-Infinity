class Trade < ActiveRecord::Base
	belongs_to :backtest
	belongs_to :stock
	
	def self.insert_or_update(trade_hash)
		Trade.create(trade_hash)
	end
end
