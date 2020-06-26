# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START functions_log_helloworld]
require "functions_framework"

FunctionsFramework.http "log-helloworld" do |_request|
  # Any output sent to either stdout or stderr will be captured and written to
  # the function's logs.
  puts "Hello, stdout!"
  warn "Hello, stderr!"

  # Return the response body as a string.
  "Hello, world!"
end
# [END functions_log_helloworld]
