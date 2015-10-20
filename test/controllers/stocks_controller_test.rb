require 'test_helper'

class StocksControllerTest < ActionController::TestCase
	def setup
		@google = stocks(:google)
	end

	test "should get index" do
		get :index
		assert_response :success
		assert_not_nil assigns(:stocks)
		assert_not_nil assigns(:stock)
		#this is a weak assertion for charts rendering
		# assert_select 'div#chart-1', nil
	end

	test "button should update all quote data" do
		assert_equal nil, @google.last_price
	    VCR.use_cassette("yahoo_finance") do
		    get :mass_update
				@google.reload
		    refute_nil @google.last_price
		    assert_redirected_to root_path
			end
	end

	test "should create stock" do
		assert_difference 'Stock.count', 1 do
			VCR.use_cassette("yahoo_finance") do
	      post :create, stock: { ticker: "FB" }
	    end
	  end
	end

	test "should create stock histories" do
		assert_difference 'History.count', 65 do
			VCR.use_cassette("yahoo_finance") do
	      post :create, stock: { ticker: "FB" }
	    end
	  end
	end	

end