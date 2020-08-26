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

# [START functions_tips_retry]
require "functions_framework"

FunctionsFramework.cloud_event "retry_or_not" do |event|
  try_again = event.data["retry"]

  begin
    # Simulate a failure
    raise "I failed!"
  rescue RuntimeError => e
    FunctionsFramework.logger.warn "Caught an error: #{e}"
    if try_again
      # Raise an exception to return a 500 and trigger a retry.
      FunctionsFramework.logger.info "Trying again..."
      raise ex
    else
      # Return normally to end processing of this event.
      FunctionsFramework.logger.info "Giving up."
    end
  end
end
# [END functions_tips_retry]
