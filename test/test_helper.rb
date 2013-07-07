ENV["RAILS_ENV"] = "test"
ENV['MOBILE_APP_SECRET'] = "lonoti"
require 'coveralls'
Coveralls.wear!('rails')
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase

  unless Test::Unit::TestCase.const_defined?('FIXTURE_CLASS_MAP')
    # Fixture name to class name map to be used in set_fixture_class and
    # rake load_fixtures task.
    Test::Unit::TestCase::FIXTURE_CLASS_MAP = {
      :events => AbstractEvent
    }
  end

  self.use_transactional_fixtures = true
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all
  set_fixture_class FIXTURE_CLASS_MAP

  # Add more helper methods to be used by all tests here...

  def json_response
    ActiveSupport::JSON.decode @response.body
  end
end
