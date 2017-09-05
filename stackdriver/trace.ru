# [START trace_configure]
require "google/cloud/trace"

Google::Cloud.configure do |config|
  # Stackdriver Trace specific parameters
  config.trace.project_id = "YOUR-PROJECT-ID"
  config.trace.keyfile    = "/path/to/service-account.json"
end
# [END trace_configure]

# [START trace_middleware]
require "google/cloud/trace"

use Google::Cloud::Trace::Middleware
# [END trace_middleware]

run Proc.new { |env| ["200", {"Content-Type" => "text/html"}, ["Hello world!"]] }
