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

# [START functions_cloudevent_storage]
# [START functions_helloworld_storage]
require "functions_framework"

FunctionsFramework.cloud_event "hello_gcs" do |event|
  # This function supports all Cloud Storage events.
  # The `event` parameter is a CloudEvents::Event::V1 object.
  # See https://cloudevents.github.io/sdk-ruby/latest/CloudEvents/Event/V1.html
  payload = event.data

  logger.info "Event: #{event.id}"
  logger.info "Event Type: #{event.type}"
  logger.info "Bucket: #{payload['bucket']}"
  logger.info "File: #{payload['name']}"
  logger.info "Metageneration: #{payload['metageneration']}"
  logger.info "Created: #{payload['timeCreated']}"
  logger.info "Updated: #{payload['updated']}"
end
# [END functions_cloudevent_storage]
# [END functions_helloworld_storage]
