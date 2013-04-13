require_relative './../../test_helper.rb'

class Api::RegistrationsControllerTest < ActionController::TestCase
  
  def test_restrict_api_access
    post :create
    assert_response :unauthorized
  end

end
