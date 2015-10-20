class CreateBacktests < ActiveRecord::Migration
  def change
    create_table :backtests do |t|
    	t.decimal :value_start
    	t.decimal :value_end
    	t.decimal :return

    	t.boolean :dollar_cost_average, default: false
    	t.string :buy_signal
    	t.string :sell_signal

      t.timestamps null: false
    end
  end
end
