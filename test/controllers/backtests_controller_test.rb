require 'test_helper'

class BacktestsControllerTest < ActionController::TestCase
  setup do
    @backtest = backtests(:basic_test)
  end

  test "should create backtest" do
    VCR.use_cassette("yahoo_finance") do
      get :new
      assert_difference('Backtest.count') do
        post :create, backtest: {
          query_start: DateTime.new(2015,10,19),
          query_end: (DateTime.new(2015,10,19) - 1.year)
        }
      end
    end

    assert_redirected_to backtest_path(assigns(:backtest))
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:backtests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end


  test "should show backtest" do
    get :show, id: @backtest
    assert_response :success
  end

  test "should destroy backtest" do
    assert_difference('Backtest.count', -1) do
      delete :destroy, id: @backtest
    end

    assert_redirected_to backtests_path
  end
end
