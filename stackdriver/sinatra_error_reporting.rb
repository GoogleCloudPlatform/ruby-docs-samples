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
    raise "Something went wrong"
  rescue StandardError => e
    Google::Cloud::ErrorReporting.report e
  end
  # [END error_reporting_exception]
end
