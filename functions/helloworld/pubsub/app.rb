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

# [START functions_cloudevent_pubsub]
# [START functions_helloworld_pubsub]
require "functions_framework"
require "base64"

FunctionsFramework.cloud_event "hello_pubsub" do |event|
  # The event parameter is a CloudEvents::Event::V1 object.
  # See https://cloudevents.github.io/sdk-ruby/latest/CloudEvents/Event/V1.html
  name = Base64.decode64 event.data["message"]["data"] rescue "World"

  # A cloud_event function does not return a response, but you can log messages
  # or cause side effects such as sending additional events.
  logger.info "Hello, #{name}!"
end
# [END functions_cloudevent_pubsub]
# [END functions_helloworld_pubsub]
