class Backtest < ActiveRecord::Base
	has_many :backtest_stocks
	has_many :stocks, through: :backtest_stocks
end
