class CreateBacktestStocks < ActiveRecord::Migration
  def change
    create_table :backtest_stocks do |t|
    	t.belongs_to :stock, index: true
    	t.belongs_to :backtest, index: true

      t.timestamps null: false
    end
  end
end
