require 'test_helper'

class StockTest < ActiveSupport::TestCase
  def setup
  	@google = stocks(:google)
  	@yahoo = stocks(:yahoo)
  end

  test 'correctly updates current stock data' do
    VCR.use_cassette("yahoo_finance") do
    	Stock.current_price
    end
    @google.reload
    assert_equal "Alphabet Inc.", @google.name
    assert_equal 643.61, @google.last_price.to_f
    assert_equal DateTime.new(2015,10,9,16), @google.last_trade 
    assert_equal "NMS", @google.stock_exchange
  end
end
