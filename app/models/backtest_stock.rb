class BacktestStock < ActiveRecord::Base
	belongs_to :stock
	belongs_to :backtest
end
