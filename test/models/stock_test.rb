require 'test_helper'

class StockTest < ActiveSupport::TestCase
  def setup
  	@google = stocks(:google)
  	@yahoo = stocks(:yahoo)
    @stock = Stock.new(ticker: "XYZ", name: "BBQ")
  end

  test "ticker should be present" do
    @stock.ticker = ""
    assert_not @stock.valid?
  end

  test "ticker should be unique" do
    @stock.ticker = "GOOG"
    assert_not @stock.valid?
  end

  test "name should be present" do
    @stock.name = ""
    assert_not @stock.valid?
  end
end
