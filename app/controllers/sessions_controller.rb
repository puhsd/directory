class SessionsController < ApplicationController
  def create
    user = User.from_omniauth(env["omniauth.auth"])
    if user
      session[:user_id] = user.id
      flash[:notice] = "Login was successfull"
    else
       flash[:notice] = "User not found"
    end
      redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "You have been successfully logged out."
    redirect_to root_path
  end
end
