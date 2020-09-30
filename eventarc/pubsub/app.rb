# Copyright 2020 Google, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START eventarc_pubsub_server]
require "sinatra"
require "json"
require "base64"

set :bind, "0.0.0.0"
port = ENV["PORT"] || "8080"
set :port, port
# [END eventarc_pubsub_server]

# [START eventarc_pubsub_handler]
post "/" do
  request.body.rewind # in case someone already read it

  body = JSON.parse request.body.read
  data = Base64.decode64 body["message"]["data"]
  if data.empty?
    data = "World"
  end
  id = request.env["HTTP_CE_ID"]
  if request.has_header? "ce-id"
    id = request.get_header "ce-id"
  end

  result = "Hello #{data}! ID: #{id}"
  puts result
  result
end
# [END eventarc_pubsub_handler]
