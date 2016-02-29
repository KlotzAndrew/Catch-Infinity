require 'test_helper'
require_relative '../../../lib/catch_infinity/fetcher/stocks'

class StocksTest < ActionController::TestCase
  def setup
  	@google = stocks(:google)
  	@yahoo = stocks(:yahoo)
  end

  test 'correctly returns hash of quotes' do
    mock_stocks_reponse = [
      {
        ticker: "GOOG",
        name: "Alphabet Inc.",
        last_price:  BigDecimal.new("705.07"),
        last_trade: DateTime.new(2016,2,26,16,00),
        stock_exchange: "NMS"
      },
      {
        ticker: "YHOO",
        name: "Yahoo! Inc.",
        last_price: BigDecimal.new("31.37"),
        last_trade: DateTime.new(2016,2,26,16,00),
        stock_exchange: "NMS"
      }
    ]

    VCR.use_cassette("yahoo_finance") do
    	fetcher = Fetcher::Stocks.new([@google.ticker, @yahoo.ticker])
    	assert_equal mock_stocks_reponse, fetcher.fetch
    end
  end
end