require 'rails_helper'

RSpec.describe WeatherService, type: :service do
  let(:zip_code) { '10001' }
  let(:api_client) { instance_double(Weather::V1::Client) }
  let(:weather_service) { described_class.new(zip_code, api_client: api_client) }

  describe "#get_weather" do
    context "when the data is in the cache" do
      let(:cached_weather_data) do
        {
          current_weather: { condition_text: 'Clear', temp_f: 72.0 },
          forecast: [ { date: '2025-10-15', condition_text: 'Partly cloudy' } ],
          cached_at: Time.now - 5.minutes
        }
      end

      before do
        allow(Rails.cache).to receive(:read).with(zip_code).and_return(cached_weather_data)
      end

      it "returns the cached weather data" do
        result = weather_service.get_weather

        expect(result[:from_cache]).to be true
        expect(result[:remaining_time]).to eq(24)
        expect(result[:current_weather]).to eq(cached_weather_data[:current_weather])
      end
    end

    context "when the data is not in the cache" do
      let(:weather_data_from_api) do
        {
          current_weather: { condition_text: 'Clear', temp_f: 72.0 },
          forecast: [ { date: '2025-10-15', condition_text: 'Partly cloudy' } ],
          cached_at: Time.now
        }
      end

      before do
        allow(Rails.cache).to receive(:read).with(zip_code).and_return(nil)
        allow(api_client).to receive(:fetch_weather).with(zip_code).and_return(weather_data_from_api)
        allow(Rails.cache).to receive(:write).with(zip_code, weather_data_from_api, expires_in: WeatherService::CACHE_EXPIRATION).and_return(true)
      end

      it "fetches the weather data from the API and caches it" do
        result = weather_service.get_weather

        expect(result[:from_cache]).to be false
        expect(result[:remaining_time]).to eq(30)
        expect(result[:current_weather]).to eq(weather_data_from_api[:current_weather])

        expect(Rails.cache).to have_received(:write).with(zip_code, weather_data_from_api, expires_in: WeatherService::CACHE_EXPIRATION)
      end
    end

    context "when the API client raises an error" do
      before do
        allow(Rails.cache).to receive(:read).with(zip_code).and_return(nil)
        allow(api_client).to receive(:fetch_weather).with(zip_code).and_raise(Weather::V1::Client::WeatherServiceApiError, 'API error')
      end

      it "returns an error message" do
        result = weather_service.get_weather

        expect(result).to eq({ error: 'API error' })
      end
    end
  end

  describe "private methods" do
    describe "#calculate_remaining_time" do
      it "calculates the remaining cache time correctly" do
        result = weather_service.send(:calculate_remaining_time, 1800)

        expect(result).to eq(30)
      end
    end
  end
end
