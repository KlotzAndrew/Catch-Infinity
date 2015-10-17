class CreateHistories < ActiveRecord::Migration
  def change
    create_table :histories do |t|
      t.integer :stock_id
      t.datetime :date
      t.decimal :price_day_close

      t.timestamps null: false
    end
  end
end
