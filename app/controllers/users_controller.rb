class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :index
  before_action :set_user, only: [:show, :edit, :update]
  # after_action :verify_authorized, except: [:index, :show, :edit]

  # GET /users
  # GET /users.json
  def index

    # @users = (params[:u] != "" ? User.all.order("ldap_attributes -> 'sn'") : User.find(:all, :conditions => ["id != ?", params[:u]]))
    if params[:q]
        @users = User.where("ldap_attributes@> hstore('physicaldeliveryofficename', ?)", search_params[:site])
    else
        @users = User.all()
    end
    respond_to do |format|
      format.html
      format.json
      format.js do
        render :json => @users, :callback => params[:callback]
      end
    end
    # @users = User.earch(params[:q])

    # puts params[:q]

    # @q = User.ransack(params[:q])
    # puts @q.result.name
    # @users = @q.result
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
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
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


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      # params.require(:user).permit(:object_guid, :username, :ldap_imported_at, :ldap_attributes)
      params.require(:user).permit(:access_level)
    end

    def search_params
      # params.require(:user).permit(:object_guid, :username, :ldap_imported_at, :ldap_attributes)
      params.require(:q).permit(:site) if params[:q]
    end
end
