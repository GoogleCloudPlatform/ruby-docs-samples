# Copyright 2020 Google LLC
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

# [START gae_standard_metadata]
require "sinatra"
require "net/http"

get "/" do
  uri = URI.parse(
    "http://metadata.google.internal/computeMetadata/v1" +
    "/instance/zone"
  )

  request = Net::HTTP::Get.new uri.path
  request.add_field "Metadata-Flavor", "Google"

  http = Net::HTTP.new uri.host, uri.port

  response = http.request request

  "Zone: #{response.body}"
end
# [END gae_standard_metadata]
