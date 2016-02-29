ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/mini_test'
require 'minitest/reporters'
Minitest::Reporters.use!

module ActiveSupport
  class TestCase
    fixtures :all

    VCR.configure do |config|
      config.cassette_library_dir = 'fixtures/vcr_cassettes'
      config.hook_into :webmock
      config.default_cassette_options = {
        match_requests_on: [:uri],
        record: :new_episodes }
    end
  end
end
