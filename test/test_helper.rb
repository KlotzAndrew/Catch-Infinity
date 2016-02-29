ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/mini_test'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

    VCR.configure do |config|
		config.cassette_library_dir = "fixtures/vcr_cassettes"
		config.hook_into :webmock
		config.default_cassette_options = {
	        match_requests_on: [:uri],
	    	record: :new_episodes }
	end
end
