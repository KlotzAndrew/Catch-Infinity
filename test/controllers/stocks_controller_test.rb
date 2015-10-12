require 'test_helper'

class StocksControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stocks)

    assert_select 'div#chart-1', nil
  end

end
