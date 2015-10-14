require 'test_helper'

class StocksControllerTest < ActionController::TestCase
	def setup
		@google = stocks(:google)
	end

	test "should get index" do
		get :index
		assert_response :success
		assert_not_nil assigns(:stocks)
		#this is a weak assertion for charts rendering
		assert_select 'div#chart-1', nil
	end

	test "button should update quote data" do
		assert_equal nil, @google.last_price
	    VCR.use_cassette("yahoo_finance") do
		    get :current_quotes
				@google.reload
		    refute_nil @google.last_price
		    assert_redirected_to root_path
			end
	end

	test "button should update past price" do
		assert_equal 0, @google.HistoricalPrices.count
	    VCR.use_cassette("yahoo_finance") do
		    get :past_prices
				@google.reload
		    assert_operator @google.HistoricalPrices.count, :>=,  50
		    assert_redirected_to root_path
			end
	end

end