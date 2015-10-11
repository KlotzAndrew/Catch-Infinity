require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
	test "layout links" do
		get root_path
		assert_template 'stocks/index'
	end
end