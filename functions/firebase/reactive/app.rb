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

# [START functions_firebase_reactive]
require "functions_framework"

FunctionsFramework.on_startup do
  # Lazily construct a Firestore client when needed, and reuse it on
  # subsequent calls.
  set_global :firestore_client do
    require "google/cloud/firestore"
    Google::Cloud::Firestore.new project_id: ENV["GOOGLE_CLOUD_PROJECT"]
  end
end

# Converts strings added to /messages/{pushId}/original to uppercase
FunctionsFramework.cloud_event "make_upper_case" do |event|
  # Event-triggered Ruby functions receive a CloudEvents::Event::V1 object.
  # See https://cloudevents.github.io/sdk-ruby/latest/CloudEvents/Event/V1.html
  # The Firebase event payload can be obtained from the event data.
  cur_value = event.data["value"]["fields"]["original"]["stringValue"]

  # Compute new value and determine whether it needs to be modified.
  # If the value is already upper-case, don't perform another write,
  # to avoid infinite loops.
  new_value = cur_value.upcase
  if cur_value == new_value
    logger.info "Value is already upper-case"
    return
  end

  # Use the Firestore client library to update the value.
  # The document name can be obtained from the event subject.
  logger.info "Replacing value: #{cur_value} --> #{new_value}"
  doc_name = event.subject.split("documents/").last
  affected_doc = global(:firestore_client).doc doc_name
  new_doc_data = { original: new_value }
  affected_doc.set new_doc_data, merge: false
end
# [END functions_firebase_reactive]
