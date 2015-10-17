require 'test_helper'

class HistoriesControllerTest < ActionController::TestCase
  def setup
		@google = stocks(:google)
	end

	test "mass_update should update histories" do
		assert_equal 0, @google.histories.count
	    VCR.use_cassette("yahoo_finance") do
		    get :mass_update
				@google.reload
		    assert_operator @google.histories.count, :>=,  50
		    assert_redirected_to root_path
			end
	end

end
