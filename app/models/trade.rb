# === Schema Information
#
# Table name: trades
#
# id                   :integer    not null, primary key
# backtest_id          :integer
# stock_id             :string
# quantity             :integer
# buy_price            :decimal
# buy_date             :datetime
# sell_price           :decimal
# sell_date            :datetime
# created_at           :datetime   null: false
# updated_at           :datetime   null: false
# TODO: Fix stock_id data type
class Trade < ActiveRecord::Base
  belongs_to :backtest
  belongs_to :stock

  def self.insert_or_update(trade_hash)
    Trade.create(trade_hash)
  end
end
