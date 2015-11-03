require 'test_helper'

class BacktestsControllerTest < ActionController::TestCase
  setup do
    @backtest = backtests(:basic_test)
    @google = stocks(:google)
    @tesla = stocks(:tesla)
  end

  test "should create backtest" do
    VCR.use_cassette("yahoo_finance") do
      get :new
      assert_difference('Backtest.count') do
        post :create, backtest: {
          "query_start(1i)" => 2015,
          "query_start(2i)" => 10,
          "query_start(3i)" => 22,
          "query_end(1i)" => 2014,
          "query_end(2i)" => 10,
          "query_end(3i)" => 22,
          stocks: ["", "#{@google.id}", "#{@tesla.id}"],
          value_start: 10000
        }
      end
    end

    assert_redirected_to backtests_path
  end
  
  test "should get index" do
    @backtest.update(query_end: 1.year.ago) if @backtest.query_end.nil?
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
