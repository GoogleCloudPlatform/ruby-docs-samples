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

# [START functions_firebase_firestore]
require "functions_framework"

# Triggered by a change to a Firestore document.
FunctionsFramework.cloud_event "hello_firestore" do |event|
  # The event parameter is a CloudEvents::Event::V1 object.
  # See https://cloudevents.github.io/sdk-ruby/latest/CloudEvents/Event/V1.html
  payload = event.data

  logger.info "Function triggered by change to: #{event.source}"
  logger.info "Old value: #{payload['oldValue']}"
  logger.info "New value: #{payload['value']}"
end
# [END functions_firebase_firestore]
