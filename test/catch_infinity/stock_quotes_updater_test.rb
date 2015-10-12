require 'test_helper'
require_relative '../../lib/catch_infinity/stock_quote_updater'

class StockQuoteUpdatrTest < ActionController::TestCase
  def setup
  	@google = stocks(:google)
  	@yahoo = stocks(:yahoo)
  end

  test 'correctly updates current stock data' do
    VCR.use_cassette("yahoo_finance") do
    	StockQuoteUpdater.new(Stock.all)
      @google.reload
      assert_equal "Alphabet Inc.", @google.name
      assert_equal 647.2, @google.last_price.to_f
      assert_equal DateTime.new(2015,10,12,12,49), @google.last_trade 
      assert_equal "NMS", @google.stock_exchange
    end
  end
end