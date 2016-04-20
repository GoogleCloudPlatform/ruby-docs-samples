# Copyright 2016 Google, Inc
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

require "sinatra"
require "slim"
require "json"
require "base64"
require "gcloud"

gcloud = Gcloud.new
pubsub = gcloud.pubsub

# [START envvars]
topic  = pubsub.topic ENV["PUBSUB_TOPIC"]
PUBSUB_VERIFICATION_TOKEN = ENV["PUBSUB_VERIFICATION_TOKEN"]
# [END envvars]

# [START messages]
# List of all messages received by this instance
messages = []
# [END messages]

# [START index]
get "/" do
  @messages = messages

  slim :index
end

post "/publish" do
  topic.publish params[:payload]

  redirect "/"
end
# [END index]

# [START push]
post "/pubsub/push" do
  halt 400 if params[:token] != PUBSUB_VERIFICATION_TOKEN

  message = JSON.parse request.body.read
  payload = Base64.decode64 message["message"]["data"]

  messages.push payload
end
# [END push]

__END__

@@index
doctype html
html
  head
    title Pub/Sub Ruby on Google App Engine Managed VMs
  body
    p Messages received by this instance:
    ul
      - @messages.each do |message|
        li = message
    p
      small
        | Note: because your application is likely running multiple instances,
        | each instance will have a different list of messages.

    / [START form]
    form method="post" action="publish"
      textarea name="payload" placeholder="Enter message here."
      input type="submit" value="Send"
    / [END form]
