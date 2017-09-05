require "sinatra"

# [START logging_configure]
require "google/cloud/logging"

Google::Cloud.configure do |config|
  # Stackdriver Logging specific parameters
  config.logging.project_id = "YOUR-PROJECT-ID"
  config.logging.keyfile    = "/path/to/service-account.json"
end
# [END logging_configure]

# [START logging_middleware]
require "google/cloud/logging"

use Google::Cloud::Logging::Middleware
# [END logging_middleware]

get "/" do
# [START logging_example]
  logger.info "Hello World!"
  logger.error "Oh No!"
# [END logging_example]
end
