require 'test_helper'
require_relative '../../lib/catch_infinity/stock_quote_updater'

class StockQuoteUpdatrTest < ActionController::TestCase
  def setup
  	@google = stocks(:google)
  	@yahoo = stocks(:yahoo)
  end

  test 'corrctly returns hash of quotes' do
    # yahoo API uses differnt format for single ticker 
    VCR.use_cassette("yahoo_finance") do
    	fetcher = StockQuoteUpdater.new([@google, @yahoo])

    	assert_equal fetcher.fetch_latest, {
			"GOOG" => 
			{
				name: "Google Inc.",
				last_price:  BigDecimal.new("646.67"),
				last_trade: DateTime.new(2015,10,12,16,00),
				stock_exchange: "NMS" 
			},
      "YHOO" => 
      {
        name: "Yahoo! Inc.",
        last_price: BigDecimal.new("32.86"),
        last_trade: DateTime.new(2015,10,12,16,00),
        stock_exchange: "NMS" 
      }
		}
    end
  end
end