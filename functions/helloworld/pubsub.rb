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

# [START functions_helloworld_pubsub]
require "functions_framework"
require "base64"

FunctionsFramework.cloud_event "hello-pubsub" do |event|
  # The event parameter is a FunctionsFramework::CloudEvents::Event object.
  # See https://www.rubydoc.info/gems/functions_framework/FunctionsFramework/CloudEvents/Event
  name = Base64.decode64 event.data["message"]["data"] rescue "World"
  # A background function does not return a response, but you can log messages
  # or cause side effects such as sending additional events.
  FunctionsFramework.logger.info "Hello, #{name}!"
end
# [END functions_helloworld_pubsub]
