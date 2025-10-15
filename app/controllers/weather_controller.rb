class WeatherController < ApplicationController
  before_action :set_zip_code, only: [ :weather_for_zip_code ]

  def index; end

  def weather_for_zip_code
    weather_service = WeatherService.new(@zip_code)
    result = weather_service.get_weather

    if result[:error]
      flash[:error] = result[:error]
      render :index
    else
      @current_weather = result[:weather]["current"]
      @forecast = result[:weather]["forecast"]["forecastday"]
      @from_cache = result[:from_cache]
      @remaining_time = result[:remaining_time]
      render :index
    end
  end

  private

  def set_zip_code
    @zip_code = weather_params[:zip_code]
  end

  def weather_params
    params.permit(:zip_code, :commit)
  end
end
