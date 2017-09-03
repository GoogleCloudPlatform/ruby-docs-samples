require_relative "sinatra_error_reporting"

# [START error_reporting_middleware]
require "google/cloud/error_reporting"

use Google::Cloud::ErrorReporting::Middleware
# [END error_reporting_middleware]

# [START error_reporting_configure]
require "google/cloud/error_reporting"

Google::Cloud.configure do |config|
  # Stackdriver Error Reporting specific parameters
  config.error_reporting.project_id = "YOUR-PROJECT-ID"
  config.error_reporting.keyfile    = "/path/to/service-account.json"
end
# [END error_reporting_configure]

run Sinatra::Application
