require_relative './../../test_helper.rb'

class Api::RegistrationsControllerTest < ActionController::TestCase
  
  def test_restrict_api_access
    post :create
    assert_response :unauthorized
  end

  def test_create_failure
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials("lonoti")
    post :create, email: "test", phone_number: "123456", devise_id: "abc123"
    assert_response 422

    assert_equal ["is invalid"], json_response['email']
    assert_equal ["can't be blank"], json_response['password']
    assert_equal ["can't be blank"], json_response['registration_id']
  end

  def test_create_success
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials("lonoti")

    post :create, email: "test@gmail.com", password: "12345678", phone_number: "123456", devise_id: "abc123", registration_id: "123456789"
    assert_response 201

    user= User.last

    assert_equal "test@gmail.com", json_response['email']
    assert_equal user.authentication_token, json_response['auth_token']

    assert_equal "test@gmail.com", user.email
    assert_equal "123456", user.phone_number
    assert_equal "abc123", user.devise_id
    assert_equal "123456789", user.registration_id
  end

end
