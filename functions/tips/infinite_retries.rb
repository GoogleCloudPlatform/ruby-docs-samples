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

# [START functions_tips_infinite_retries]
require "functions_framework"

FunctionsFramework.cloud_event "avoid_infinite_retries" do |event|
  # Use the event timestamp to determine the event age.
  event_age_secs = Time.now - event.time.to_time
  event_age_ms = (event_age_secs * 1000).to_i

  max_age_ms = 10_000
  if event_age_ms > max_age_ms
    # Ignore events that are too old.
    FunctionsFramework.logger.info "Dropped #{event.id} (age #{event_age_ms}ms)"

  else
    # Do what the function is supposed to do.
    FunctionsFramework.logger.info "Handling #{event.id} (age #{event_age_ms}ms)..."
    failed = true

    # Raise an exception to signal failure and trigger a retry.
    raise "I failed!" if failed
  end
end
# [END functions_tips_infinite_retries]
