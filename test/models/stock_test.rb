require 'test_helper'

class StockTest < ActiveSupport::TestCase
  def setup
  	@google = stocks(:google)
  	@yahoo = stocks(:yahoo)
    @stock = Stock.new
  end

  test 'correctly updates current stock data' do
    VCR.use_cassette("yahoo_finance") do
    	Stock.current_price([@google, @yahoo])
      @google.reload
      assert_equal "Google Inc.", @google.name
      assert_equal BigDecimal.new("646.67"), @google.last_price
      assert_equal DateTime.new(2015,10,12,16,00), @google.last_trade 
      assert_equal "NMS", @google.stock_exchange
    end
  end

  test 'correctly updates current single stock data' do
    VCR.use_cassette("yahoo_finance") do
      Stock.current_price([@google])
      @google.reload
      assert_equal "Alphabet Inc.", @google.name
      assert_equal BigDecimal.new("646.67"), @google.last_price
      assert_equal DateTime.new(2015,10,12,16,00), @google.last_trade 
      assert_equal "NMS", @google.stock_exchange
    end
  end


  test 'correctly fetches histoical stock data' do
    VCR.use_cassette("yahoo_finance") do
      Stock.past_prices([@google, @yahoo])
    end

    Stock.all.each do |stock|
      assert_operator stock.HistoricalPrices.count, :>=,  50

      stock.HistoricalPrices.each do |hist|
          refute_nil hist.price_day_close
          refute_nil hist.date
          assert_equal hist.stock_id, stock.id
      end
    end
  end

  test 'builds stock history for new valid stocks' do
    VCR.use_cassette("yahoo_finance") do
      stock = Stock.new(ticker: "FB")
      Stock.current_price([stock])
      
      stock = Stock.where(ticker: stock.ticker).first
      assert_operator stock.HistoricalPrices.count, :>=,  50
    end
  end

  test "ticker should be present" do
    @stock.ticker = ""
    assert_not @stock.valid?
  end

  test "ticker should be unique" do
    @stock.ticker = "GOOG"
    assert_not @stock.valid?
  end
end
