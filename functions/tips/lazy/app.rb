# Copyright 2021 Google LLC
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

def file_wide_computation
  numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]
  numbers.reduce :+
end

def function_specific_computation
  numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]
  numbers.reduce :*
end

# [START functions_tips_lazy_globals]
FunctionsFramework.on_startup do
  # This method is called when the function is initialized, not on each
  # invocation.

  # Declare and set non_lazy_global
  set_global :non_lazy_global, file_wide_computation

  # Declare, but do not set, lazy_global
  set_global :lazy_global do
    function_specific_computation
  end
end

FunctionsFramework.http "tips_lazy" do |_request|
  # This method is called every time this function is called.

  "Lazy: #{global :lazy_global}; non_lazy: #{global :non_lazy_global}"
end
# [END functions_tips_lazy_globals]
