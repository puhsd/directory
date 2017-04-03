class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :index
  before_action :set_user, only: [:show, :edit, :update]
  # after_action :verify_authorized, except: [:index, :show, :edit]

  # GET /users
  # GET /users.json
  def index

    if params[:q]
      @users = User.load_users(current_user,search_params[:site],search_params[:hasphone])
    else
      @users = User.load_users(current_user)
    end

    respond_to do |format|
      format.html
      format.json
      # format.js
      format.js do
        render :json => User.jsonp_format(@users), :callback => params[:callback]
      end
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        if params[:user][:avatar]
             @user.processimage(params[:user][:avatar].tempfile) if params[:user][:avatar].content_type == 'image/jpeg'
        end
          # @user.processimage(params)
        format.html { redirect_to @user, notice: "User was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  def ldap_sync
      authorize User, :ldap_sync?
      call_rake :ldap_sync
      flash[:notice] = "LDAP Sync Initiated"
      redirect_to users_url
  end

  def import
    authorize(current_user, @user)
    if params[:u]
      @user = User.find_by(username: params[:u])
      if User.import_from_ldap(params[:u])
        redirect_to @user, notice: 'Successfully synchronized users with LDAP.'
      else
        redirect_to @user, alert: 'Could not synchronize users with LDAP.'
      end
    else
      if User.import_from_ldap
        redirect_to users_url, notice: 'Successfully synchronized users with LDAP.'
      else
        redirect_to users_url, alert: 'Could not synchronize users with LDA.'
      end
    end
  end

  def default_url
    authorize(current_user, @user)
    if params[:u]
      @user = User.find_by(username: params[:u])
      @user.set_default_url
      redirect_to @user, notice: 'Successfully reset to default url.'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      # params.require(:user).permit(:object_guid, :username, :ldap_imported_at, :ldap_attributes)
      params.require(:user).permit(:access_level, :link)
    end

    def search_params
      # params.require(:user).permit(:object_guid, :username, :ldap_imported_at, :ldap_attributes)
      params.require(:q).permit(:site, :hasphone) if params[:q]
    end
end
