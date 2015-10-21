class CreateBacktests < ActiveRecord::Migration
  def change
    create_table :backtests do |t|
    	t.decimal :value_start
    	t.decimal :value_end
    	t.boolean :dollar_cost_average, default: false
    	t.string :buy_signal
    	t.string :sell_signal
      t.datetime :query_start
      t.datetime :query_end

      t.timestamps null: false
    end
  end
end
