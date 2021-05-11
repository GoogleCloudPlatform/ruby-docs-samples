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

# rubocop:disable Style/GlobalVars

# [START functions_concepts_stateless]
require "functions_framework"

# Global variable, but scoped only within one function instance.
$count = 0

FunctionsFramework.http "execution_count" do |_request|
  $count += 1

  # NOTE: the total function invocation count across all instances
  # may not be equal to this value!
  "Instance execution count: #{$count}"
end
# [END functions_concepts_stateless]

# rubocop:enable Style/GlobalVars
