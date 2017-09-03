# [START shared_configure]
# Add this to config/environments/*.rb
Rails.application.configure do |config|
  # Stackdriver Shared parameters
  config.google_cloud.project_id = "YOUR-PROJECT-ID"
  config.google_cloud.keyfile    = "/path/to/service-account.json"
end
# [END shared_configure]

# [START debugger_configure]
# Add this to config/environments/*.rb
Rails.application.configure do |config|
  # Stackdriver Debugger specific parameters
  config.google_cloud.debugger.project_id = "YOUR-PROJECT-ID"
  config.google_cloud.debugger.keyfile    = "/path/to/service-account.json"
end
# [END debugger_configure]

# [START trace_configure]
# Add this to config/environments/*.rb
Rails.application.configure do |config|
  # Stackdriver Trace specific parameters
  config.google_cloud.trace.project_id = "YOUR-PROJECT-ID"
  config.google_cloud.trace.keyfile    = "/path/to/service-account.json"
end
# [END trace_configure]

# [START error_reporting_configure]
# Add this to config/environments/*.rb
Rails.application.configure do |config|
  # Stackdriver Error Reporting specific parameters
  config.google_cloud.error_reporting.project_id = "YOUR-PROJECT-ID"
  config.google_cloud.error_reporting.keyfile    = "/path/to/service-account.json"
end
# [END error_reporting_configure]

# [START logging_configure]
# Add this to config/environments/*.rb
Rails.application.configure do |config|
  # Stackdriver Logging specific parameters
  config.google_cloud.logging.project_id = "YOUR-PROJECT-ID"
  config.google_cloud.logging.keyfile    = "/path/to/service-account.json"
end
# [END logging_configure]
