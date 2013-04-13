class Api::SessionsController < Devise::SessionsController
  before_filter :ensure_params_exist
 
  def create
    build_resource
    resource = User.find_for_database_authentication(email: params[:email])
 
    if resource && resource.valid_password?(params[:password])
      render json: {auth_token: resource.authentication_token, email: resource.email}
    else
      return invalid_login_attempt
    end
  end
  
  # def destroy
  #   sign_out(resource_name)
  # end
 
  protected

  def ensure_params_exist
    return unless params[:email].blank? || params[:password].blank?
    render json: {message: "missing user_login parameter"}, status: 422
  end
 
  def invalid_login_attempt
    warden.custom_failure!
    render json: {message: "Error with your login or password"}, status: 401
  end
end
