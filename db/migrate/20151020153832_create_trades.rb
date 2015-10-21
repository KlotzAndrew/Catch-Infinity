class CreateTrades < ActiveRecord::Migration
  def change
    create_table :trades do |t|
    	t.integer :backtest_id
    	t.string :stock_id
    	t.integer :quantity
    	t.decimal :buy_price
    	t.datetime :buy_date
    	t.decimal :sell_price
    	t.datetime :sell_date

      t.timestamps null: false
    end
  end
end
