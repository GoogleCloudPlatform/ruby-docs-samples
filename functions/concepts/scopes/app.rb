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

# This is called once, on cold start
def cold_start_time
  Time.now
end

def invocation_time
  Time.now
end

# [START functions_concepts_scopes]
# Calling the cold start method
global = cold_start_time

FunctionsFramework.http "concepts_scopes" do |_request|
  # Per-function scope
  # This method is called every time this function is called
  function_var = invocation_time

  "instance: #{global}; function: #{function_var}"
end
# [END functions_concepts_scopes]
