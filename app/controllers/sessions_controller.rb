class SessionsController < ApplicationController
  def create
    # user = User.from_omniauth(env["omniauth.auth"])
    user = authenticate_with_google
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

  private
    def authenticate_with_google
      if flash[:google_sign_in_token].present?
        # receive_info = GoogleSignIn::Identity.new(flash[:google_sign_in_token])
        # puts receive_info
        email = GoogleSignIn::Identity.new(flash[:google_sign_in_token]).email_address
        # User.find_by google_id: GoogleSignIn::Identity.new(flash[:google_sign_in_token]).user_id
        User.import_from_ldap(email.split("@").first)

        user = User.find_by(username: email.split("@").first)
        return user
      end
    end

end
