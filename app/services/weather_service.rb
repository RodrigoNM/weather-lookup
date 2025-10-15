class WeatherService
  CACHE_EXPIRATION = 3.minutes

  def initialize(zip_code, cache: Rails.cache, api_client: Weather::V1::Client.new)
    @zip_code = zip_code
    @cache = cache
    @api_client = api_client
  end

  def get_weather
    cached_data = @cache.read(@zip_code)

    if cached_data
      remaining_time = [ CACHE_EXPIRATION - (Time.now - cached_data[:cached_at]), 0 ].max

      return {
        weather: cached_data[:weather],
        from_cache: true,
        remaining_time: remaining_time
      }
    end

    weather_data = @api_client.fetch_weather(@zip_code)

    cached_data = {
      weather: weather_data,
      cached_at: Time.now
    }

    @cache.write(@zip_code, cached_data, expires_in: CACHE_EXPIRATION)

    {
      weather: weather_data,
      from_cache: false,
      remaining_time: CACHE_EXPIRATION.to_i
    }
  rescue Weather::V1::Client::WeatherServiceApiError => e
    { error: e.message }
  end
end
