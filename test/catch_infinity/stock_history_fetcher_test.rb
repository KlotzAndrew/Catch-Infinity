require 'test_helper'
require_relative '../../lib/catch_infinity/stock_history_fetcher'

class StockHistoryFetcherTest < ActionController::TestCase
	def setup
  	@google = stocks(:google)
  end

  test 'corrctly returns hash of historical prices' do
  	VCR.use_cassette("yahoo_finance") do
  		fetcher = StockHistoryFetcher.new([@google])

  		prices = fetcher.fetch
			assert_equal prices["GOOG"].first, 
			[
				DateTime.new(2015,10,14),
				{
					price_day_close: BigDecimal.new("659.390015")
				}
			]
			assert_equal prices["GOOG"].count, 65	
  	end

  end

end