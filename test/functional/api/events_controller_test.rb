require_relative './../../test_helper.rb'

class Api::EventsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    super
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials("lonoti")
  end

  def test_authenitcation
    post :create, auth_token: 'szcPqx4pAsszfLLxQun'
    assert_response :unauthorized
    assert_equal "authentication error", json_response['error']
  end

  def test_failure_invalid_json_data
    assert_no_difference "AbstractEvent.count" do
      post :create, data: "23.013", auth_token: users(:test_user).authentication_token
    end 
    assert_response 422

    assert_equal "invalid json data", json_response['error']
  end

############################## Invalid params tests start ###################################################    

  def test_failure_invalid_action
    params_json = create_base64encoded({action: 10})

    assert_no_difference "AbstractEvent.count" do
      post :create, data: params_json, auth_token: users(:test_user).authentication_token
    end 
    assert_response 422

    assert_equal "invalid action", json_response['error']
  end

  def test_failure_invalid_params_combination_for_create_without_payload
    params_json = create_base64encoded({action: Api::EventsController::Action::CREATE})

    assert_no_difference "AbstractEvent.count" do
      post :create, data: params_json, auth_token: users(:test_user).authentication_token
    end 
    assert_response 422

    assert_equal "payload and type must be present for create action", json_response['error']
  end

  def test_failure_invalid_params_combination_for_create_without_payload_type
    params_json = create_base64encoded({action: Api::EventsController::Action::CREATE, payload: {}})

    assert_no_difference "AbstractEvent.count" do
      post :create, data: params_json, auth_token: users(:test_user).authentication_token
    end 
    assert_response 422

    assert_equal "payload and type must be present for create action", json_response['error']
  end

  def test_failure_invalid_params_combination_for_update_without_event_id
    params_json = create_base64encoded({action: Api::EventsController::Action::UPDATE, payload: {}})

    assert_no_difference "AbstractEvent.count" do
      post :create, data: params_json, auth_token: users(:test_user).authentication_token
    end 
    assert_response 422

    assert_equal "event_id and payload must be present for update action", json_response['error']
  end

  def test_failure_invalid_params_combination_for_update_without_payload
    params_json = create_base64encoded({action: Api::EventsController::Action::UPDATE, event_id: 123456})

    assert_no_difference "AbstractEvent.count" do
      post :create, data: params_json, auth_token: users(:test_user).authentication_token
    end 
    assert_response 422

    assert_equal "event_id and payload must be present for update action", json_response['error']
  end

  def test_failure_invalid_params_combination_for_status_without_event_id
    params_json = create_base64encoded({action: Api::EventsController::Action::STATE_CHANGE, status: AbstractEvent::State::ACTIVE})

    assert_no_difference "AbstractEvent.count" do
      post :create, data: params_json, auth_token: users(:test_user).authentication_token
    end 
    assert_response 422

    assert_equal "event_id and status must be present for state change action", json_response['error']
  end

  def test_failure_invalid_params_combination_for_status_without_status
    params_json = create_base64encoded({action: Api::EventsController::Action::STATE_CHANGE, event_id: 123456})

    assert_no_difference "AbstractEvent.count" do
      post :create, data: params_json, auth_token: users(:test_user).authentication_token
    end 
    assert_response 422
    assert_equal "event_id and status must be present for state change action", json_response['error']
  end

############################## Invalid params tests end ###################################################  

############################## Create ###################################################  

  def test_create_failure_invalid_type
    params_json = create_base64encoded({action: Api::EventsController::Action::CREATE, payload: {type: 3}})

    assert_no_difference "AbstractEvent.count" do
      post :create, data: params_json, auth_token: users(:test_user).authentication_token
    end 
    assert_response 422

    assert_equal "invalid value for type", json_response['error']
  end

  def test_create_failure_time_based
    payload = {type: Api::EventsController::Type::TIME_BASED, time: {}}
    params_json = create_base64encoded({action: Api::EventsController::Action::CREATE, payload: payload})
    assert_no_difference "Event::TimeBased.count" do
      post :create, data: params_json, auth_token: users(:test_user).authentication_token
    end 
    assert_response 422
    assert_equal ["can't be blank"], json_response["title"]
    assert_equal ["can't be blank"], json_response["message"]
    assert_equal ["can't be blank"], json_response["trigger_time"]
    assert assigns(:event).is_a?(Event::TimeBased)
    assert_equal users(:test_user), assigns(:event).user
  end

  def test_create_failure_location_based
    payload = {type: Api::EventsController::Type::LOCATION_BASED, location: {}}
    params_json = create_base64encoded({action: Api::EventsController::Action::CREATE, payload: payload})
    assert_no_difference "Event::LocationBased.count" do
      post :create, data: params_json, auth_token: users(:test_user).authentication_token
    end 
    assert_response 422
    assert_equal ["can't be blank"], json_response["title"]
    assert_equal ["can't be blank"], json_response["message"]
    assert_equal ["can't be blank"], json_response["lat"]
    assert_equal ["can't be blank"], json_response["lng"]
    assert_equal ["can't be blank"], json_response["distance_from_address"]
    assert assigns(:event).is_a?(Event::LocationBased)
    assert_equal users(:test_user), assigns(:event).user
    assert_equal false, assigns(:event).send_location?
  end

  def test_create_failure_invalid_friends
    payload = {type: Api::EventsController::Type::TIME_BASED, time: {datetime: Time.now.to_i.to_s}, title: "Title", message: "Sample Message"}
    payload[:friends] = [{:phone_number => nil}]
    params_json = create_base64encoded({action: Api::EventsController::Action::CREATE, payload: payload})

    assert_no_difference "AbstractEvent.count" do
      post :create, data: params_json, auth_token: users(:test_user).authentication_token
    end

    assert_response 422
    assert_equal ["is invalid"], json_response["event_users"]
    assert_equal users(:test_user), assigns(:event).user
    assert_equal "Title", assigns(:event).title
    assert_equal "Sample Message", assigns(:event).message
    assert assigns(:event).is_a?(Event::TimeBased)
  end

  def test_create_success_time_based
    t = Time.now
    payload = {type: Api::EventsController::Type::TIME_BASED, time: {datetime: t.to_i.to_s, send_location: 1, repeats_on_week: "0,1"}, title: "Title", message: "Sample Message"}
    payload[:friends] = [{phone_number: "9840463195", email: "mrudhu@gmail.com"}, {phone_number: "9177023195"}]

    params_json = create_base64encoded({action: Api::EventsController::Action::CREATE, payload: payload})

    assert_difference "Event::TimeBased.count" do
      assert_difference "EventUser.count", 2 do
        post :create, data: params_json, auth_token: users(:test_user).authentication_token
      end
    end 

    event = Event::TimeBased.last
    assert_response 200
    assert_equal event.id, json_response["event_id"]
    assert_equal users(:test_user), event.user
    assert_equal "Title", event.title
    assert_equal "Sample Message", event.message
    assert_equal t.to_i, event.trigger_time.to_i
    assert_equal "0,1", event.repeats_on_week
    assert event.send_location?

    assert event.lat.nil?
    assert event.lng.nil?
    assert event.distance_from_address.nil?
    assert event.address.nil?

    assert_equal ["9840463195", "9177023195"], event.event_users.collect(&:phone_number)
    assert_equal ["mrudhu@gmail.com", nil], event.event_users.collect(&:email)
  end

  def test_create_success_location_based
    payload = {type: Api::EventsController::Type::LOCATION_BASED, location: {lat: "44.9817",lng: "-93.2783", distance: 500}, title: "Title", message: "Sample Message"}
    payload[:friends] = [{phone_number: "9840463195", email: "mrudhu@gmail.com"}, {phone_number: "9177023195"}]

    params_json = create_base64encoded({action: Api::EventsController::Action::CREATE, payload: payload})

    assert_difference "Event::LocationBased.count" do
      assert_difference "EventUser.count", 2 do
        post :create, data: params_json, auth_token: users(:test_user).authentication_token
      end
    end 

    event = Event::LocationBased.last
    assert_response 200
    assert_equal event.id, json_response["event_id"]
    assert_equal users(:test_user), event.user
    assert_equal "Title", event.title
    assert_equal "Sample Message", event.message
    assert event.trigger_time.nil?
    assert event.repeats_on_week.nil?
    assert !event.send_location?

    assert_equal "-93.2783", event.lng.to_s
    assert_equal "44.9817", event.lat.to_s
    assert_equal 500, event.distance_from_address
    assert_equal "353 North 5th Street, Minneapolis, MN 55403, USA", event.address

    assert_equal ["9840463195", "9177023195"], event.event_users.collect(&:phone_number)
    assert_equal ["mrudhu@gmail.com", nil], event.event_users.collect(&:email)
  end


############################## Create End ###################################################  

############################## Update ################################################### 
  def test_update_sucess_time_based
    event = events(:test_time_event)
    t = Time.now
    payload = {time: {datetime: t.to_i.to_s, send_location: 0, repeats_on_week: "0,1"}, title: "Title", message: "Sample Message"}

    assert_equal "Sample time message", event.message
    assert_equal "Test time", event.title
    assert (t.to_i != event.trigger_time)
    assert_equal "1,2,3,4,5", event.repeats_on_week
    assert event.send_location?

    params_json = create_base64encoded({action: Api::EventsController::Action::UPDATE, payload: payload, event_id: event.id})
    assert_no_difference "Event::TimeBased.count" do
      post :create, data: params_json, auth_token: users(:test_user).authentication_token
    end 
    assert_response 200
    assert_equal event.id, json_response["event_id"]
    
    assert_equal "Sample Message", event.reload.message
    assert_equal "Title", event.title
    assert_equal t.to_i, event.trigger_time.to_i
    assert_equal "0,1", event.repeats_on_week
    assert !event.send_location?
  end

  def test_update_sucess_time_based_with_few_params
    event = events(:test_time_event)
    t = Time.now
    payload = {time: {datetime: t.to_i.to_s}}

    assert_equal "Sample time message", event.message
    assert_equal "Test time", event.title
    assert (t.to_i != event.trigger_time)
    assert_equal "1,2,3,4,5", event.repeats_on_week
    assert event.send_location?

    params_json = create_base64encoded({action: Api::EventsController::Action::UPDATE, payload: payload, event_id: event.id})
    assert_no_difference "Event::TimeBased.count" do
      post :create, data: params_json, auth_token: users(:test_user).authentication_token
    end 
    assert_response 200
    assert_equal event.id, json_response["event_id"]
    
    assert_equal "Sample time message", event.reload.message
    assert_equal "Test time", event.title
    assert_equal t.to_i, event.trigger_time.to_i
    assert_equal "1,2,3,4,5", event.repeats_on_week
    assert event.send_location?
  end

  def test_update_sucess_time_based_with_friends
    event = events(:test_time_event)
    t = Time.now
    payload = {friends: [{phone_number: "9177023915", email: "mrudhukar@chronus.com"}, {phone_number: "9704957756"}, {phone_number: "000"}]}

    assert_equal ["9177023915", "8978381829"], event.event_users.collect(&:phone_number)
    assert_equal ["mrudhu@gmail.com", nil], event.event_users.collect(&:email)

    params_json = create_base64encoded({action: Api::EventsController::Action::UPDATE, payload: payload, event_id: event.id})
    assert_difference "EventUser.count" do
      post :create, data: params_json, auth_token: users(:test_user).authentication_token
    end 
    assert_response 200
    assert_equal event.id, json_response["event_id"]

    assert_equal ["9177023915", "9704957756", "000"], event.reload.event_users.collect(&:phone_number)
    assert_equal ["mrudhukar@chronus.com", nil, nil], event.event_users.collect(&:email)
  end

  def test_update_sucess_location_based
    event = events(:test_loc_event)
    payload = {location: {lat: "42.700149",lng: "-74.922767", distance: 1000}, title: "Title", message: "Sample Message"}

    assert_equal "Sample location message", event.message
    assert_equal "Test location", event.title
    assert_equal "-93.2783", event.lng.to_s
    assert_equal "44.9817", event.lat.to_s
    assert_equal 500, event.distance_from_address

    params_json = create_base64encoded({action: Api::EventsController::Action::UPDATE, payload: payload, event_id: event.id})
    assert_no_difference "Event::TimeBased.count" do
      post :create, data: params_json, auth_token: users(:test_user).authentication_token
    end 
    assert_response 200
    assert_equal event.id, json_response["event_id"]
    
    assert_equal "Sample Message", event.reload.message
    assert_equal "Title", event.title
    assert_equal "-74.922767", event.lng.to_s
    assert_equal "42.700149", event.lat.to_s
    assert_equal 1000, event.distance_from_address
  end


############################## Update End ###################################################  


############################## Status ###################################################  

  def test_update_status_failure_404
    params_json = create_base64encoded({action: Api::EventsController::Action::STATE_CHANGE, status: AbstractEvent::State::INACTIVE, event_id: 145})

    assert_no_difference "AbstractEvent.count" do
      post :create, data: params_json, auth_token: users(:test_user).authentication_token
    end 
    assert_response 404
    assert_equal "cannot find the event with event_id", json_response['error']
  end

  def test_update_status_success
    params_json = create_base64encoded({action: Api::EventsController::Action::STATE_CHANGE, status: AbstractEvent::State::INACTIVE, event_id: 1})
    assert_equal AbstractEvent::State::ACTIVE, events(:test_time_event).status

    assert_no_difference "AbstractEvent.count" do
      post :create, data: params_json, auth_token: users(:test_user).authentication_token
    end 
    assert_response 200
    assert_equal "status has been updated to 1", json_response['success']

    assert_equal AbstractEvent::State::INACTIVE, events(:test_time_event).reload.status
    assert_equal AbstractEvent::State::INACTIVE, assigns(:decoded_params)[:status]
    assert_equal 1, assigns(:decoded_params)[:event_id]
    assert_equal events(:test_time_event), assigns(:event)
  end
############################## Status End ###################################################  

  def test_dummy
    # assert_difference "UserLocation.count" do
    #   post :create, lat: "44.9817",lng: "-93.2783", sent_at: t.to_i.to_s, auth_token: users(:test_user).authentication_token
    # end

    # loc = UserLocation.last

    # assert_equal "-93.2783", loc.lng.to_s
    # assert_equal "44.9817", loc.lat.to_s
    # assert_equal t.to_i, loc.sent_at.to_i
    # assert_equal users(:test_user), loc.user
    # assert_equal "353 North 5th Street, Minneapolis, MN 55403, USA", loc.address
  end

  private

  def create_base64encoded(hash)
    Base64.encode64(hash.to_json)
  end
end
