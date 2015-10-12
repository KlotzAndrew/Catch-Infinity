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

	test "buttons should update stock data" do
		# assert_equal nil, @google.last_price
	 #    VCR.use_cassette("yahoo_finance") do
		#     get :yahoo_api
		# end
		# @google.reload
	 #    refute_nil @google.last_price
	end

end