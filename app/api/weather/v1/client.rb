module Weather
  module V1
    class Client
      class WeatherServiceApiError < StandardError; end
      BASE_URL = "https://api.weatherapi.com/v1".freeze

      def initialize
        @client = HTTParty
      end

      def fetch_weather(zip_code)
        response = @client.get("#{BASE_URL}/forecast.json", query: { q: zip_code, days: 3, key: ENV["WEATHER_API_KEY"] })

        if response.success?
          response.parsed_response
        else
          error_message = ErrorHandlingService.handle_api_error(response.parsed_response)
          raise WeatherServiceApiError, error_message
        end
      end
    end
  end
end
