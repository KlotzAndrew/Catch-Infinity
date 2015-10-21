class Trade < ActiveRecord::Base
	belongs_to :backtest
	
	def self.insert_or_update(trade_hash)
		Trade.create(trade_hash)
	end
end
