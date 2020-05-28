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

# [START functions_helloworld_storage]
require "functions_framework"

FunctionsFramework.cloud_event "hello-gcs" do |event|
  # The event parameter is a FunctionsFramework::CloudEvents::Event object.
  # See https://www.rubydoc.info/gems/functions_framework/FunctionsFramework/CloudEvents/Event
  payload = event.data
  filename = payload["name"]
  if payload["resourceState"] == "not_exists"
    FunctionsFramework.logger.info "File #{filename} deleted."
  elsif payload["metageneration"] == "1"
    # The "metageneration" attribute is updated on metadata changes.
    # On create, its value is "1".
    FunctionsFramework.logger.info "File #{filename} uploaded."
  else
    FunctionsFramework.logger.info "File #{filename} metadata updated."
  end
end
# [END functions_helloworld_storage]
