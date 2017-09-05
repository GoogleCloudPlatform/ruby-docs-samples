require "sinatra"

# [START error_reporting_configure]
require "google/cloud/error_reporting"

Google::Cloud.configure do |config|
  # Stackdriver Error Reporting specific parameters
  config.error_reporting.project_id = "YOUR-PROJECT-ID"
  config.error_reporting.keyfile    = "/path/to/service-account.json"
end
# [END error_reporting_configure]

# [START error_reporting_middleware]
require "google/cloud/error_reporting"

use Google::Cloud::ErrorReporting::Middleware
# [END error_reporting_middleware]

get "/" do
  "hello world"
end

get "/raise" do
# [START error_reporting_exception]
  require "google/cloud/error_reporting"

  begin
    fail "Raise an exception for Error Reporting."
  rescue => exception
    Google::Cloud::ErrorReporting.report exception
  end
# [END error_reporting_exception]
end

