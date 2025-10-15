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

        parsed_response = response.parsed_response
        if response.success?
          {
            current_weather: format_weather(parsed_response),
            forecast: format_forecast(parsed_response)
          }
        else
          error_message = ErrorHandlingService.handle_api_error(parsed_response)
          raise WeatherServiceApiError, error_message
        end
      end


      private

      def format_weather(parsed_response)
        current_weather = parsed_response["current"]
        {
          condition_text: current_weather["condition"]["text"],
          condition_icon: current_weather["condition"]["icon"],
          temp_f: current_weather["temp_f"],
          temp_c: current_weather["temp_c"],
          feelslike_f: current_weather["feelslike_f"],
          feelslike_c: current_weather["feelslike_c"],
          max_temp_f: current_weather["heatindex_f"],
          max_temp_c: current_weather["heatindex_c"],
          min_temp_f: current_weather["dewpoint_f"],
          min_temp_c: current_weather["dewpoint_c"],
          wind_mph: current_weather["wind_mph"],
          wind_kph: current_weather["wind_kph"],
          humidity: current_weather["humidity"]
        }
      end

      def format_forecast(parsed_response)
        forecast = parsed_response["forecast"]["forecastday"]
        forecast.map do |day|
          {
            date: day["date"],
            condition_text: day["day"]["condition"]["text"],
            condition_icon: day["day"]["condition"]["icon"],
            max_temp_f: day["day"]["maxtemp_f"],
            max_temp_c: day["day"]["maxtemp_c"],
            min_temp_f: day["day"]["mintemp_f"],
            min_temp_c: day["day"]["mintemp_c"]
          }
        end
      end
    end
  end
end
