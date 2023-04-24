# Copyright 2018 Google, Inc
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

$stdout.sync = true

# [START cloud_tasks_appengine_quickstart]
require "sinatra"
require "json"

get "/" do
  # Basic index to verify app is serving
  "Hello World!"
end

post "/log_payload" do
  data = request.body.read
  # Log the request payload
  puts "Received task with payload: #{data}"
  "Printed task payload: #{data}"
end
# [END cloud_tasks_appengine_quickstart]
