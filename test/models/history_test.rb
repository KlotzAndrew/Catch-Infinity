require 'test_helper'

class HistoricalPriceTest < ActiveSupport::TestCase
  def setup
  	@google = stocks(:google)
  end

  test "only 1 history price per day" do
  	History.create(date: DateTime.new(2015, 10,15), stock_id: @google.id)
  	history = History.create(date: DateTime.new(2015, 10,15), stock_id: @google.id)
  	assert_not history.valid?
  end

  test "history date is accurate to day only" do
  	history = History.create(date: DateTime.new(2015,10,15,9,4), stock_id: @google.id)
  	assert_equal history.date, DateTime.new(2015,10,15)
  end

  test "date should be present" do
  	history = History.create
  	assert_not history.valid?
  end
end
