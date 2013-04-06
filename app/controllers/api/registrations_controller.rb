class Api::RegistrationsController < Api::BaseController

  def create
    user = User.new(email: params[:email], password: params[:password], devise_id: params[:devise_id].presence)
    if user.save
      render json: {auth_token: user.authentication_token, email: user.email}, status: 201
      return
    else
      warden.custom_failure!
      render json: user.errors, status: 422
    end
  end
end
