class ApplicationController < ActionController::Base
  respond_to :json
  #TODO Move these to specific to api controller
  #protect_from_forgery

  skip_before_filter :verify_authenticity_token
  before_filter :restrict_api_access

  def restrict_api_access
    authenticate_or_request_with_http_token do |token, options|
      token == ENV['MOBILE_APP_SECRET']
    end
  end

  def authenticate_user_from_api
    unless current_api_user
      render :json => {'error' => 'authentication error'}, :status => 401
    end
  end
end
