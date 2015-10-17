require 'test_helper'
require_relative '../../../lib/catch_infinity/builder/charts'

class ChartDataBuilderTest < ActionController::TestCase
	def setup
  	@tesla = stocks(:tesla)
  end

  def data_hash_case
  		fetcher = Builder::Charts.new([@tesla])
  		fetcher.format_for_google
  end

  def raw_prices_builder
    raw_prices = {}
    50.downto(0) do |x|
      date = @tesla.last_trade - (x).days
      raw_prices.merge!(date => x)
    end
    return raw_prices
  end

  def avg_prices_builder(days)
    raw_prices, counter = {}, 0
    days.downto(1) do |x|
      counter +=1
      total = (x..days).to_a.sum
      date = @tesla.last_trade - (x).days
      raw_prices.merge!(date => total/counter.to_f)
    end
    return raw_prices
  end

  test 'corrctly returns stock value' do
    hash = data_hash_case
		assert_equal @tesla, hash[@tesla.ticker][:stock]
  end

  test 'corrctly returns raw prices' do
    hash = data_hash_case
    raw_prices = raw_prices_builder
    assert_equal raw_prices, hash[@tesla.ticker][:prices][:raw_prices]
  end

  test 'correctly returns avg 50 days' do
    hash = data_hash_case
    avg_prices = avg_prices_builder(50)
    assert_equal avg_prices, hash[@tesla.ticker][:prices][:avg_50_days]
  end

  test 'correctly returns avg 20 days' do
    hash = data_hash_case
    avg_prices = avg_prices_builder(20)
    assert_equal avg_prices, hash[@tesla.ticker][:prices][:avg_20_days]
  end

  test 'correctly returns breakout value' do
    hash = data_hash_case
    price = raw_prices_builder
    trend = avg_prices_builder(20)
    breakout_value = price.values.last - trend.values.last
    assert_equal breakout_value, hash[@tesla.ticker][:prices][:today_jump]
  end
end