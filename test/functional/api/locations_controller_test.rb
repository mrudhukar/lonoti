require_relative './../../test_helper.rb'

class Api::LocationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    super
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials("lonoti")
  end

  def test_authenitcation
    post :create, lat: "23.013",lng: "123.013", sent_at: Time.now.to_i.to_s, auth_token: 'szcPqx4pAsszfLLxQun'
    assert_response :unauthorized
    assert_equal "authentication error", json_response['error']
  end

  def test_create_failure

    assert_no_difference "UserLocation.count" do
      post :create, lat: "23.013", sent_at: Time.now.to_i.to_s, auth_token: users(:test_user).authentication_token
    end 
    assert_response 422

    assert_equal ["can't be blank"], json_response['lng']
  end

  def test_create_success
    t = Time.now

    assert_difference "UserLocation.count" do
      post :create, lat: "23.013",lng: "123.013", sent_at: t.to_i.to_s, auth_token: users(:test_user).authentication_token
    end

    assert_response :success

    loc = UserLocation.last

    assert_equal "123.013", loc.lng.to_s
    assert_equal "23.013", loc.lat.to_s
    assert_equal t.to_i, loc.sent_at.to_i
    assert_equal users(:test_user), loc.user
  end

end
