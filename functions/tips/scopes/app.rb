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

require "functions_framework"

def perform_heavy_computation
  Time.now
end

def perform_light_computation
  Time.now
end

# [START functions_tips_scopes]
# Global (instance-wide) scope.
# This block runs on cold start, before any function is invoked.
#
# Note: It is usually best to run global initialization in an on_startup block
# instead at the top level of the Ruby file. This is because top-level code
# could be executed to verify the function during deployment, whereas an
# on_startup block is run only when an actual function instance is starting up.
FunctionsFramework.on_startup do
  instance_data = perform_heavy_computation

  # To pass data into function invocations, the best practice is to set a
  # key-value pair using the Ruby Function Framework's built-in "set_global"
  # method. Functions can call the "global" method to retrieve the data by key.
  # (You can also use Ruby global variables or "toplevel" local variables, but
  # they can make it difficult to isolate global data for testing.)
  set_global :my_instance_data, instance_data
end

FunctionsFramework.http "tips_scopes" do |_request|
  # Per-function scope.
  # This method is called every time this function is called.
  invocation_data = perform_light_computation

  # Retrieve the data computed by the on_startup block.
  instance_data = global :my_instance_data

  "instance: #{instance_data}; function: #{invocation_data}"
end
# [END functions_tips_scopes]
