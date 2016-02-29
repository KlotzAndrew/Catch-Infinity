# === Schema Information
#
# Table name: backtest_stocks
#
# id                   :integer    not null, primary key
# stock_id             :integer
# backtest_id          :integer
# created_at           :datetime   null: false
# updated_at           :datetime   null: false
class BacktestStock < ActiveRecord::Base
  belongs_to :stock
  belongs_to :backtest
end
