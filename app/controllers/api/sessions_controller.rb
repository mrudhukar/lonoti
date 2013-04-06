class Api::SessionsController < Api::BaseController
  prepend_before_filter :require_no_authentication, only: [:create ]

  before_filter :ensure_params_exist
 
  def create
    build_resource
    resource = User.find_for_database_authentication(email: params[:email])
    return invalid_login_attempt unless resource
 
    if resource.valid_password?(params[:password])
      sign_in("user", resource)
      render json: {auth_token: resource.authentication_token, email: resource.email}
      return
    end
    invalid_login_attempt
  end
  
  def destroy
    sign_out(resource_name)
  end
 
  protected
  def ensure_params_exist
    return unless params[:email].blank? && params[:password].blank?
    render json: {message: "missing user_login parameter"}, status: 422
  end
 
  def invalid_login_attempt
    warden.custom_failure!
    render json: {message: "Error with your login or password"}, status: 401
  end
end
