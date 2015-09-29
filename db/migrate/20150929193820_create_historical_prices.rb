class CreateHistoricalPrices < ActiveRecord::Migration
  def change
    create_table :historical_prices do |t|
      t.string :ticker
      t.integer :date
      t.integer :price

      t.timestamps null: false
    end
  end
end
