# Copyright 2019 Google LLC
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

require "base64"
require "json"
# [START run_pubsub_server_setup]
require "sinatra"

set :bind, "0.0.0.0"
# [END run_pubsub_server_setup]

# [START run_pubsub_handler]
post "/" do
  begin
    body = JSON.parse request.body.read
  rescue JSON::ParserError => error
    body = request.body.read
  end

  if body.empty?
    msg = "no Pub/Sub message received"
    logger.error "error: #{msg}"
    return [400, msg]
  end

  if body["message"].nil?
    msg = "invalid Pub/Sub message format"
    logger.error "error: #{msg}"
    return [400, msg]
  end

  name = "World"
  if body["message"]["data"]
    name = Base64.decode64 body["message"]["data"]
  end

  logger.info "Hello #{name}!"
  return 204
end
