class Api::EventsController < ApplicationController

  module Action
    CREATE = 0
    UPDATE = 1
    STATE_CHANGE = 2
  end

  module Type
    TIME_BASED = 0
    LOCATION_BASED = 1
  end

  before_filter :authenticate_user_from_api, :get_params_from_json

  def create
    unless @decoded_params
      @response_to_send = [{'error' => 'invalid json data'}, 422]
    else
      @action = @decoded_params[:action]
      @status = @decoded_params[:status]
      @event_id = @decoded_params[:event_id]

      @event_params = @decoded_params[:payload].symbolize_keys if @decoded_params[:payload]

      if (error_message = invalid_params_combinations).present?
        @response_to_send = [error_message, 422]
      else
        execute_action
      end
    end

    render json: @response_to_send[0], status: @response_to_send[1]
  end

  private

  def invalid_params_combinations
    case @action
    when Action::CREATE
      {'error' => 'payload and type must be present for create action'} unless @event_params && @event_params[:type]
    when Action::UPDATE
      {'error' => 'event_id and payload must be present for update action'} unless @event_id && @event_params
    when Action::STATE_CHANGE
      {'error' => 'event_id and status must be present for state change action'} unless @event_id && @status
    else
      {'error' => 'invalid action'}
    end
  end

  def execute_action
    case @action
    when Action::CREATE
      p_create
    when Action::UPDATE
      p_update
    when Action::STATE_CHANGE
      p_statechage
    end
  end

  def p_create
    if @event_params[:type] == Type::TIME_BASED && @event_params[:time]

      time_params = @event_params[:time].symbolize_keys
      time_params[:trigger_date] = Time.at(time_params.delete(:date_sec).to_i).beginning_of_day() if time_params[:date_sec].present?
      @event = current_api_user.time_events.new(time_params) 

    elsif @event_params[:type] == Type::LOCATION_BASED && @event_params[:location]

      loc_params = @event_params[:location].symbolize_keys
      loc_params[:distance_from_address] = loc_params.delete(:distance)
      @event = current_api_user.location_events.new(loc_params)

    else
      @response_to_send = [{'error' => "invalid value for type"}, 422]
      return
    end

    @event.title = @event_params[:title]
    @event.message =  @event_params[:message]

    if @event_params[:friends]
      @event.event_users.build(@event_params[:friends])
      @event.event_users.each{|eu| eu.event = @event}
    end

    if @event.save
      @response_to_send = [{event_id: @event.id}, 200]
    else
      @response_to_send = [@event.errors, 422]
    end
  end

  def p_update
    return unless check_event_presence

    final_params = {title: @event_params[:title], message: @event_params[:message]}

    if @event_params[:time]
      time_params = @event_params[:time].symbolize_keys
      final_params[:trigger_date] = Time.at(time_params.delete(:date_sec).to_i).beginning_of_day() if time_params[:date_sec].present?
      final_params.merge!(time_params)
    elsif @event_params[:location]
      loc_params = @event_params[:location].symbolize_keys
      final_params[:distance_from_address] = loc_params.delete(:distance)
      final_params.merge!(loc_params)
    end

    final_params.delete_if { |k, v| v.nil? }

    @event.attributes = final_params

    #Intitate the call only if the event is valid
    if @event.valid? && @event_params[:friends]
      @event.update_and_build_event_users(@event_params[:friends])
    end

    if @event.save
      @response_to_send = [{event_id: @event.id}, 200]
    else
      @response_to_send = [@event.errors, 422]
    end
  end

  def p_statechage
    return unless check_event_presence

    @event.status = @status.to_i
    @event.save!
    @response_to_send = [{'success' => "status has been updated to #{@status.to_i}"}, 200]
  end

  def check_event_presence
    @event = current_api_user.events.find_by_id(@event_id)
    unless @event
      @response_to_send = [{'error' => "cannot find the event with event_id"}, 404]
      return false
    else
      return true
    end
  end

end
