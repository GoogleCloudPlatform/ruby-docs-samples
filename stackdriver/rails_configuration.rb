# Copyright 2017 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START logging_rails_shared_configure]
# Add this to config/environments/*.rb
Rails.application.configure do |config|
  # Stackdriver Shared parameters
  config.google_cloud.project_id = "YOUR-PROJECT-ID"
  config.google_cloud.keyfile    = "/path/to/service-account.json"
end
# [END logging_rails_shared_configure]

# [START debugger_configure]
# Add this to config/environments/*.rb
Rails.application.configure do |config|
  # Stackdriver Debugger specific parameters
  config.google_cloud.debugger.project_id = "YOUR-PROJECT-ID"
  config.google_cloud.debugger.keyfile    = "/path/to/service-account.json"
end
# [END debugger_configure]

# [START debugger_configure_development]
# Add this to config/environments/development.rb
Rails.application.configure do |config|
  config.google_cloud.use_debugger = true
end
# [END debugger_configure_development]

# [START trace_configure]
# Add this to config/environments/*.rb
Rails.application.configure do |config|
  # Stackdriver Trace specific parameters
  config.google_cloud.trace.project_id = "YOUR-PROJECT-ID"
  config.google_cloud.trace.keyfile    = "/path/to/service-account.json"
end
# [END trace_configure]

# [START trace_configure_development]
# Add this to config/environments/development.rb
Rails.application.configure do |config|
  config.google_cloud.use_trace = true
end
# [END trace_configure_development]

# [START error_reporting_configure]
# Add this to config/environments/*.rb
Rails.application.configure do |config|
  # Stackdriver Error Reporting specific parameters
  config.google_cloud.error_reporting.project_id = "YOUR-PROJECT-ID"
  config.google_cloud.error_reporting.keyfile    = "/path/to/service-account.json"
end
# [END error_reporting_configure]

# [START error_reporting_configure_development]
# Add this to config/environments/development.rb
Rails.application.configure do |config|
  config.google_cloud.use_error_reporting = true
end
# [END error_reporting_configure_development]

# [START logging_rails_client_configure]
# Add this to config/environments/*.rb
Rails.application.configure do |config|
  # Stackdriver Logging specific parameters
  config.google_cloud.logging.project_id = "YOUR-PROJECT-ID"
  config.google_cloud.logging.keyfile    = "/path/to/service-account.json"
end
# [END logging_rails_client_configure]

# [START logging_rails_client_configure_development]
# Add this to config/environments/development.rb
Rails.application.configure do |config|
  config.google_cloud.use_logging = true
end
# [END logging_rails_client_configure_development]
