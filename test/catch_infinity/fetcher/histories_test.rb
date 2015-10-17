require 'test_helper'
require_relative '../../../lib/catch_infinity/fetcher/histories'

class FetcherHistoriesTest < ActionController::TestCase
	def setup
  	@google = stocks(:google)
  end

  test 'corrctly returns hash of historical prices' do
  	VCR.use_cassette("yahoo_finance") do
  		fetcher = Fetcher::Histories.new([@google.ticker])

  		prices = fetcher.fetch
			assert_equal prices["GOOG"].first, 
				{
					date: DateTime.new(2015,10,16),
					price_day_close: BigDecimal.new("664.969971")
				}
			assert_equal prices["GOOG"].count, 65	
  	end

  end

end