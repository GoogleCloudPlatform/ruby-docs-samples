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

# rubocop:disable Style/GlobalVars

# [START gae_flex_websockets]
require "sinatra"
require "faye/websocket"
require "thin"

Faye::WebSocket.load_adapter "thin"

# For the purposes of this example, use a global variable to keep track of
# all connected clients in order to send chat messages. This approach limits
# us to a single server and a single process; a more robust solution would be
# to pass messages via e.g. Cloud Memorystore or Cloud Pub/Sub.
$all_clients = []

get "/" do
  erb :index
end

get "/chat" do
  if Faye::WebSocket.websocket? request.env
    ws = Faye::WebSocket.new request.env

    ws.on :open do
      $all_clients.push ws
    end

    ws.on :message do |msg|
      # Send the message to every connected client (including self)
      $all_clients.each do |client|
        client.send msg.data
      end
    end

    ws.on :close do
      $all_clients.delete ws
    end

    # Return async Rack response
    ws.rack_response
  else
    erb :index
  end
end

# [END gae_flex_websockets]
# rubocop:enable Style/GlobalVars
