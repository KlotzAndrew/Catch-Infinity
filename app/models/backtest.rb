# === Schema Information
#
# Table name: backtests
#
# id                   :integer    not null, primary key
# value_start          :decimal
# value_end            :decimal
# dollar_cost_average  :boolean    default: false
# buy_signal           :string
# sell_signal          :string
# query_start          :datetime
# query_end            :datetime
# created_at           :datetime   null: false
# updated_at           :datetime   null: false
class Backtest < ActiveRecord::Base
  has_many :backtest_stocks
  has_many :stocks, through: :backtest_stocks
  has_many :trades

  validates :value_start, presence: true
  validates :value_end, presence: true
  validates :query_end, presence: true
  validates :query_end, presence: true

  def self.insert_or_update(backtest_hash)
    Backtest.create(backtest_hash)
  end
end
