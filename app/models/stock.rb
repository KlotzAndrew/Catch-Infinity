require_relative '../../lib/catch_infinity/fetcher/stocks'
require_relative '../../lib/catch_infinity/fetcher/histories'

# === Schema Information
#
# Table name: stocks
#
# id                  :integer    not null, primary key
# ticker              :string
# name                :string
# stock_exchange      :string
# last_price          :decimal
# last_trade          :datetime
# created_at          :datetime   null: false
# updated_at          :datetime   null: false
class Stock < ActiveRecord::Base
  has_many :histories
  has_many :backtest_stocks
  has_many :backtests, through: :backtest_stocks
  has_many :trades

  validates :ticker, uniqueness: true, length: { minimum: 1 }
  validates :name, presence: true

  def self.insert_or_update(stock_hashes)
    Stock.transaction do
      stock_hashes.each do |stock_hash|
        stock = Stock.where(ticker: stock_hash[:ticker]).first
        update_or_create_stock(stock, stock_hash)
      end
    end
  rescue => e
    Rails.logger.info("There was an exception: #{e}")
  end

  private

  def update_or_create_stock(stock, stock_hash)
    if stock
      stock.update!(stock_hash)
    else
      Stock.create!(stock_hash)
    end
  end
end
