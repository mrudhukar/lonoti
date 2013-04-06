class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :restrict_access

  def restrict_access
    authenticate_or_request_with_http_token do |token, options|
      token == ENV['MOBILE_APP_SECRET']
    end
  end
end
