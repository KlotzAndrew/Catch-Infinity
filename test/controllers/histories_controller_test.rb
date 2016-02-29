require 'test_helper'

class HistoriesControllerTest < ActionController::TestCase
  def setup
		@google = stocks(:google)
	end

	test "mass_update should update histories" do
		Fetcher::Histories.any_instance.expects(:fetch).returns(true)

		get :mass_update

		assert_redirected_to root_path
	end

end
