class CreateHistoricalPrices < ActiveRecord::Migration
  def change
    create_table :historical_prices do |t|
      t.integer :stock_id
      t.datetime :date
      t.decimal :price_day_close

      t.timestamps null: false
    end
  end
end
