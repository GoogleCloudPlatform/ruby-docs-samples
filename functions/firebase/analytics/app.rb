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

# [START functions_firebase_analytics]
require "functions_framework"

# Triggered by a Google Analytics for Firebase log event.
FunctionsFramework.cloud_event "hello_analytics" do |event|
  # Event-triggered Ruby functions receive a CloudEvents::Event::V1 object.
  # See https://cloudevents.github.io/sdk-ruby/latest/CloudEvents/Event/V1.html
  # The Analytics event payload can be obtained from the `data` field.
  payload = event.data

  logger.info "Function triggered by the following event: #{event.source}"

  event = payload["eventDim"].first
  logger.info "Name: #{event['name']}"

  event_timestamp = Time.at(event["timestampMicros"].to_i / 1_000_000).utc
  logger.info "Timestamp: #{event_timestamp.strftime '%Y-%m-%dT%H:%M:%SZ'}"

  user_obj = payload["userDim"]
  logger.info "Device Model: #{user_obj['deviceInfo']['deviceModel']}"

  geo_info = user_obj["geoInfo"]
  logger.info "Location: #{geo_info['city']}, #{geo_info['country']}"
end
# [END functions_firebase_analytics]
