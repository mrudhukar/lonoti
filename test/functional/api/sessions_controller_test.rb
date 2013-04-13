require_relative './../../test_helper.rb'

class Api::SessionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    super
    setup_controller_for_warden
    request.env["devise.mapping"] = Devise.mappings[:api_user]
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials("lonoti")
  end

  def test_create_failure_password_missing
    post :create, email: "test@gmail.com"
    assert_response 422

    assert_equal "missing user_login parameter", json_response['message']
  end

  def test_create_failure_no_user
    post :create, email: "test@gmail.com", password: "12345678"
    assert_response 401

    assert_equal "Error with your login or password", json_response['message']
  end

  def test_create_failure_user_with_wrong_password
    post :create, email: "fixture@gmail.com", password: "abcdefgh"
    assert_response 401

    assert_equal "Error with your login or password", json_response['message']
  end

  def test_create_success
    post :create, email: "fixture@gmail.com", password: "12345678"
    assert_response 200

    user= User.last
    assert_equal "fixture@gmail.com", json_response['email']
    assert_equal user.authentication_token, json_response['auth_token']
  end
end
