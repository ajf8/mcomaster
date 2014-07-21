class AppSettingsController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource

  before_action :set_app_setting, only: [:show, :edit, :update, :destroy]

  # GET /app_settings
  def index
    render json: AppSetting.all
  end

  # GET /app_settings/1
  def show
    render json: AppSetting.find(params[:id])
  end

  # GET /app_settings/new
  def new
    render json: @app_setting = AppSetting.new
  end

  # GET /app_settings/1/edit
  def edit
  end

  # POST /app_settings
  def create
    @app_setting = AppSetting.new(app_setting_params)
    @app_setting.save
    render json: @app_setting

#    if @app_setting.save
#      redirect_to @app_setting, notice: 'App setting was successfully created.'
#    else
#      render action: 'new'
#    end
  end

  # PATCH/PUT /app_settings/1
  def update
    @app_setting = AppSetting.find(params[:id])
    @app_setting.update(app_setting_params)
    @app_setting.save()
    render json: @app_setting
  end

  # DELETE /app_settings/1
  def destroy
    @app_setting.destroy
    render json: 'App setting was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_app_setting
      @app_setting = AppSetting.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def app_setting_params
      params.require(:app_setting).permit(:set_key, :set_val)
    end
end
