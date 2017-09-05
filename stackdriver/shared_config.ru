# [START shared_configure]
require "stackdriver"

Google::Cloud.configure do |config|
  # Stackdriver Shared parameters
  config.project_id = "YOUR-PROJECT-ID"
  config.keyfile    = "/path/to/service-account.json"
end
# [END shared_configure]

use Google::Cloud::Debugger::Middleware
use Google::Cloud::Logging::Middleware
use Google::Cloud::ErrorReporting::Middleware
use Google::Cloud::Trace::Middleware

run Proc.new { |env| ["200", {"Content-Type" => "text/html"}, ["Hello world!"]] }
