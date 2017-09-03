# [START shared_configure]
require "stackdriver"

Google::Cloud.configure do |config|
  # Stackdriver Shared parameters
  config.project_id = "YOUR-PROJECT-ID"
  config.keyfile    = "/path/to/service-account.json"
end
# [END shared_configure]

