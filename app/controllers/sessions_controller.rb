class SessionsController < ApplicationController

  def create
    auth = request.env["omniauth.auth"]
    if auth
      user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)
    else
      user = User.authenticate(params[:email], params[:password])
    end

    if not user
      redirect_to :action => "new", :loginfail => 'true', :email=> params[:email]
    else
      session[:user_id] = user.id
      redirect_to recipes_path
    end
  end

  def new

  end

  def destroy
    session[:user_id] = nil
    redirect_to recipes_path
  end

end
