class TitlesController < ApplicationController
  before_action :set_title, only: [:show, :edit, :update, :destroy]

  # GET /titles
  # GET /titles.json
  def index
    authorize Title
    @titles_public = Title.where(public: true).order(:name)
    @titles_no_public = Title.where(public: false).order(:name)

    user_titles = User.pluck(:ldap_attributes).map{|j| j['title'].split(',') }.flatten

    @result = user_titles.each_with_object(Hash.new(0)) { |title,counts| counts[title] += 1 }

  end

  # GET /titles/1
  # GET /titles/1.json
  def show
    authorize Title
  end

  # GET /titles/new
  def new
    authorize Title
    @title = Title.new
  end

  # GET /titles/1/edit
  def edit
    authorize Title
  end

  # POST /titles
  # POST /titles.json
  def create
    authorize Title
    @title = Title.new(title_params)

    respond_to do |format|
      if @title.save
        format.html { redirect_to titles_url }
        format.js
        format.json { render :show, status: :created, location: @title }
      else
        format.html { render :new }
        format.json { render json: @title.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /titles/1
  # PATCH/PUT /titles/1.json
  def update
    authorize Title
    respond_to do |format|
      if @title.update(title_params)
        # format.html { redirect_to @title, notice: 'Title was successfully updated.' }
        format.html { redirect_to titles_url }
        format.js
        format.json { render :show, status: :ok, location: @title }
      else
        format.html { render :edit }
        format.json { render json: @title.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /titles/1
  # DELETE /titles/1.json
  def destroy
    authorize Title
    @title.destroy
    respond_to do |format|
      format.html { redirect_to titles_url, notice: 'Title was successfully destroyed.' }
      format.js
      format.json { head :no_content }
    end
  end

  def extract
    authorize Title
    if Title.extract
      redirect_to titles_url, notice: 'Successfully imported all the titles.'
    else
      redirect_to titles_url, alert: 'Could not imported all the titles.'
    end

  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_title
      @title = Title.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def title_params
      params.require(:title).permit(:name, :public)
    end
end
