class Api::LocationsController < ApplicationController
  before_filter :authenticate_user_from_api

  respond_to :json
  def create
    location = current_api_user.user_locations.new(lat: params[:lat].presence, lng: params[:lng].presence)
    location.sent_at = Time.at(params[:sent_at].presence.to_i) if params[:sent_at].present?

    if location.save
      render nothing: true, status: 200 
    else
      render json: location.errors, status: 422
    end
  end
end
