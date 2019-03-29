# Copyright 2016 Google, Inc
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

# [START logging_quickstart]
# [START require_library]
# Imports the Google Cloud client library
require "google/cloud/logging"
# [END require_library]

# Your Google Cloud Platform project ID
project_id = "YOUR_PROJECT_ID"

# Instantiates a client
logging = Google::Cloud::Logging.new project: project_id

# Prepares a log entry
entry = logging.entry
# The data to log
entry.payload = "Hello, world!"
# The name of the log to write to
entry.log_name = "my-log"
# The resource associated with the data
entry.resource.type = "global"

# Writes the log entry
logging.write_entries entry

puts "Logged #{entry.payload}"
# [END logging_quickstart]
