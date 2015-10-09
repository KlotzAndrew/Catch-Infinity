require 'test_helper'

class StockTest < ActiveSupport::TestCase
  def setup
  	@ZZZ_TO = stocks(:ZZZ_TO)
  	@RSY_V = stocks(:RSY_V)
  	@ECO_TO = stocks(:ECO_TO)
  end

  test 'correctly updates current stock data' do
  	Stock.current_price
  	assert_equal "Sleep Country", @ZZZ_TO.name
  	assert_equal 99.99, @ZZZ_TO.last_price
  	assert_equal Time.now, @ZZZ_TO.last_trade 
  	assert_equal "Toronto Stack Exchange", @ZZZ_TO.stock_exchange
  end
end
