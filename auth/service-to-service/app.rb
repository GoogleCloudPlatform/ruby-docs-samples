# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This application acts as both the target function and relay function
# for testing service-to-service authentication using Cloud Functions.

require_relative "service_auth"

FunctionsFramework.http "make_get_request_cloud-echo" do |_request|
  "Success!"
end

FunctionsFramework.http "make_get_request_cloud" do |_request|
  target_url = ENV["TARGET_URL"]

  if target_url.nil? || target_url.empty?
    raise "TARGET_URL environment variable is missing"
  end

  writer = StringIO.new
  make_get_request writer, target_url, target_url
  writer.string
end
