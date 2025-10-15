class WeatherController < ApplicationController
  before_action :set_zip_code, only: [ :weather_for_zip_code ]

  def index; end

  def weather_for_zip_code
    weather_service = WeatherService.new(@zip_code)
    result = weather_service.get_weather

    if result[:error]
      flash[:error] = result[:error]
    else
      @weather = result
    end
    render :index
  end

  private

  def set_zip_code
    @zip_code = weather_params[:zip_code]
  end

  def weather_params
    params.permit(:zip_code, :commit)
  end
end
