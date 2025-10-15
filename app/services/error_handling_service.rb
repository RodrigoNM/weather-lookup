class ErrorHandlingService
  ERROR_CODES = {
    "1002" => "API key not provided.",
    "1003" => "Parameter 'q' not provided.",
    "1005" => "API request URL is invalid.",
    "1006" => "No location found matching the parameter.",
    "2006" => "API key provided is invalid.",
    "2007" => "API key has exceeded calls per month quota.",
    "2008" => "API key has been disabled.",
    "2009" => "API key does not have access to the resource.",
    "9000" => "JSON body passed in bulk request is invalid.",
    "9001" => "Too many locations for bulk request.",
    "9999" => "Internal application error."
  }

  def self.handle_api_error(response)
    error_code = response["error"] && response["error"]["code"].to_s

    if error_code && ERROR_CODES[error_code]
      "Error #{error_code} - #{ERROR_CODES[error_code]}"
    else
      "An unknown error occurred while fetching the weather data. #{response}"
    end
  end
end
