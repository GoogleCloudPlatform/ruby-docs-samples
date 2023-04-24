# Copyright 2023 Google LLC
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

# [START gae_flex_metadata]
require "sinatra"
require "net/http"

get "/" do
  uri = URI.parse(
    "http://metadata.google.internal/computeMetadata/v1" +
    "/instance/network-interfaces/0/access-configs/0/external-ip"
  )

  request = Net::HTTP::Get.new uri.path
  request.add_field "Metadata-Flavor", "Google"

  http = Net::HTTP.new uri.host, uri.port

  response = http.request request

  "External IP: #{response.body}"
end
# [END gae_flex_metadata]
