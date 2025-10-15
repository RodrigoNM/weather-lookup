require "rails_helper"
require "webmock/rspec"

RSpec.describe Weather::V1::Client, type: :service do
  let(:client) { described_class.new }
  let(:zip_code) { '10001' }
  let(:api_key) { ENV["WEATHER_API_KEY"] }

  describe "#fetch_weather" do
    context "when the API request is successful" do
      before do
        stub_request(:get, "https://api.weatherapi.com/v1/forecast.json")
          .with(query: hash_including(q: zip_code, key: api_key))
          .to_return(
            status: 200,
            body: {
              "current" => {
                "condition" => { "text" => "Clear", "icon" => "//cdn.weatherapi.com/weather/64x64/day/113.png" },
                "temp_f" => 72.0,
                "temp_c" => 22.0,
                "feelslike_f" => 70.0,
                "feelslike_c" => 21.0,
                "heatindex_f" => 75.0,
                "heatindex_c" => 23.0,
                "dewpoint_f" => 64.0,
                "dewpoint_c" => 18.0,
                "wind_mph" => 5.0,
                "wind_kph" => 8.0,
                "humidity" => 60
              },
              "forecast" => {
                "forecastday" => [
                  {
                    "date" => "2025-10-15",
                    "day" => {
                      "condition" => { "text" => "Partly cloudy", "icon" => "//cdn.weatherapi.com/weather/64x64/day/116.png" },
                      "maxtemp_f" => 75.0,
                      "maxtemp_c" => 23.8,
                      "mintemp_f" => 60.0,
                      "mintemp_c" => 15.6
                    }
                  }
                ]
              }
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns a formatted weather response" do
        result = client.fetch_weather(zip_code)

        expect(result).to have_key(:current_weather)
        expect(result).to have_key(:forecast)
        expect(result[:current_weather]).to include(
          :condition_text, :temp_f, :humidity, :wind_mph
        )
        expect(result[:forecast].first).to include(:date, :condition_text, :max_temp_f, :min_temp_f)
      end
    end

    context "when the API request fails" do
      before do
        stub_request(:get, "https://api.weatherapi.com/v1/forecast.json")
          .with(query: hash_including(q: zip_code, key: api_key))
          .to_return(
            status: 400,
            body: '{"error": {"message": "Invalid API Key"}}',
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "raises a WeatherServiceApiError" do
        expect { client.fetch_weather(zip_code) }.to raise_error(Weather::V1::Client::WeatherServiceApiError, /Invalid API Key/)
      end
    end
  end

  describe "private methods" do
    let(:parsed_response) {
      {
        "current" => {
          "condition" => { "text" => "Clear", "icon" => "//cdn.weatherapi.com/weather/64x64/day/113.png" },
          "temp_f" => 72.0,
          "temp_c" => 22.0,
          "feelslike_f" => 70.0,
          "feelslike_c" => 21.0,
          "heatindex_f" => 75.0,
          "heatindex_c" => 23.0,
          "dewpoint_f" => 64.0,
          "dewpoint_c" => 18.0,
          "wind_mph" => 5.0,
          "wind_kph" => 8.0,
          "humidity" => 60
        },
        "forecast" => {
          "forecastday" => [
            {
              "date" => "2025-10-15",
              "day" => {
                "condition" => { "text" => "Partly cloudy", "icon" => "//cdn.weatherapi.com/weather/64x64/day/116.png" },
                "maxtemp_f" => 75.0,
                "maxtemp_c" => 23.8,
                "mintemp_f" => 60.0,
                "mintemp_c" => 15.6
              }
            }
          ]
        }
      }
    }

    describe "#format_weather" do
      it "formats current weather data correctly" do
        formatted_weather = client.send(:format_weather, parsed_response)

        expect(formatted_weather).to include(
          :condition_text, :temp_f, :feelslike_f, :max_temp_f, :min_temp_f, :wind_mph, :humidity
        )
        expect(formatted_weather[:condition_text]).to eq("Clear")
        expect(formatted_weather[:temp_f]).to eq(72.0)
      end
    end

    describe "#format_forecast" do
      it "formats the forecast data correctly" do
        formatted_forecast = client.send(:format_forecast, parsed_response)

        expect(formatted_forecast).to be_an(Array)
        expect(formatted_forecast.first).to include(:date, :condition_text, :max_temp_f, :min_temp_f)
        expect(formatted_forecast.first[:date]).to eq("2025-10-15")
      end
    end
  end
end
