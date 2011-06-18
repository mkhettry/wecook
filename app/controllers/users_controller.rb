class UsersController < ApplicationController
  def welcome
    user = current_user
    if not user.nil?
      redirect_to recipes_path
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.provider = "native"
    if @user.save
      session[:user_id] = @user.id
      redirect_to recipes_path
    else
      render "new"
    end
  end
end
