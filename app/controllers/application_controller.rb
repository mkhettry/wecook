class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user

  private
  def require_login
    redirect_to welcome_path, :notice => "You need sign in first!" if current_user.nil?
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

end
