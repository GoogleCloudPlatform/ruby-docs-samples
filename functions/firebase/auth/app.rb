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

# [START functions_firebase_auth]
require "functions_framework"

# Triggered by creation or deletion of a Firebase Auth user object.
FunctionsFramework.cloud_event "hello_auth" do |event|
  # Event-triggered Ruby functions receive a CloudEvents::Event::V1 object.
  # See https://cloudevents.github.io/sdk-ruby/latest/CloudEvents/Event/V1.html
  # The Firebase event payload can be obtained from the `data` field.
  payload = event.data

  logger.info "Function triggered by creation/deletion of user: #{payload['uid']}"
  logger.info "Created at: #{payload['metadata']['createdAt']}"
  logger.info "Email: #{payload['email']}" if payload.key? "email"
end
# [END functions_firebase_auth]
