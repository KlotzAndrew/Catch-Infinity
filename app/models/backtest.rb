class Backtest < ActiveRecord::Base
	has_many :backtest_stocks
	has_many :stocks, through: :backtest_stocks
	has_many :trades

	validates :value_end, presence: true

	def self.insert_or_update(backtest_hash)
		Backtest.create(backtest_hash)
	end
end
