class WeatherService
  CACHE_EXPIRATION = 30.minutes

  def initialize(zip_code, cache: Rails.cache, api_client: Weather::V1::Client.new)
    @zip_code = zip_code
    @cache = cache
    @api_client = api_client
  end

  def get_weather
    cached_data = @cache.read(@zip_code)

    if cached_data
      remaining_time = [ CACHE_EXPIRATION - (Time.now - cached_data[:cached_at]), 0 ].max

      return cached_data.merge(
        {
          from_cache: true,
          remaining_time: calculate_remaining_time(remaining_time)
        }
      )
    end

    weather_data = @api_client.fetch_weather(@zip_code)

    weather_data.merge!({ cached_at: Time.now })

    @cache.write(@zip_code, weather_data, expires_in: CACHE_EXPIRATION)

    weather_data.merge(
      {
        from_cache: false,
        remaining_time: calculate_remaining_time(CACHE_EXPIRATION)
      }
    )
  rescue Weather::V1::Client::WeatherServiceApiError => e
    { error: e.message }
  end

  private

  def calculate_remaining_time(remaining_time)
    (remaining_time.to_i / 60).to_i
  end
end
