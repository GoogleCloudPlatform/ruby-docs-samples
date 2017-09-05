# [START debugger_configure]
require "google/cloud/debugger"

Google::Cloud.configure do |config|
  # Stackdriver Debugger specific parameters
  config.debugger.project_id = "YOUR-PROJECT-ID"
  config.debugger.keyfile    = "/path/to/service-account.json"
end
# [END debugger_configure]

# [START debugger_middleware]
require "google/cloud/debugger"

use Google::Cloud::Debugger::Middleware
# [END debugger_middleware]

run Proc.new { |env| ["200", {"Content-Type" => "text/html"}, ["Hello world!"]] }

