require 'rails_helper'

RSpec.describe ErrorHandlingService do
  describe '.handle_api_error' do
    context 'when error code is known' do
      it 'returns the correct error message for known codes' do
        response = { "error" => { "code" => 1002 } }
        expect(described_class.handle_api_error(response)).to eq(
          "Error 1002 - API key not provided."
        )
      end

      it 'works with string error codes as well' do
        response = { "error" => { "code" => "1006" } }
        expect(described_class.handle_api_error(response)).to eq(
          "Error 1006 - No location found matching the parameter."
        )
      end
    end

    context 'when error code is unknown' do
      it 'returns a generic unknown error message' do
        response = { "error" => { "code" => 1234 } }
        expect(described_class.handle_api_error(response)).to eq(
          "An unknown error occurred while fetching the weather data. #{response}"
        )
      end
    end

    context 'when response has no error key' do
      it 'returns a generic unknown error message' do
        response = { "data" => "some data" }
        expect(described_class.handle_api_error(response)).to eq(
          "An unknown error occurred while fetching the weather data. #{response}"
        )
      end
    end

    context 'when error key is nil' do
      it 'returns a generic unknown error message' do
        response = { "error" => nil }
        expect(described_class.handle_api_error(response)).to eq(
          "An unknown error occurred while fetching the weather data. #{response}"
        )
      end
    end

    context 'when code is missing inside error key' do
      it 'returns a generic unknown error message' do
        response = { "error" => { "message" => "Something went wrong" } }
        expect(described_class.handle_api_error(response)).to eq(
          "An unknown error occurred while fetching the weather data. #{response}"
        )
      end
    end
  end
end
