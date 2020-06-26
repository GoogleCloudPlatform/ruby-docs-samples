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
  # The event parameter is a FunctionsFramework::CloudEvents::Event object.
  # See https://www.rubydoc.info/gems/functions_framework/FunctionsFramework/CloudEvents/Event
  payload = event.data

  FunctionsFramework.logger.info "Function triggered by change to: #{event.source_string}"
  FunctionsFramework.logger.info "Old value: #{payload['oldValue']}"
  FunctionsFramework.logger.info "New value: #{payload['value']}"
end
# [END functions_firebase_firestore]
