# Copyright 2015 Google, Inc
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

#[START all]
require "digest/sha2"
require "sinatra"
require "gcloud"

gcloud  = Gcloud.new
dataset = gcloud.datastore

get "/" do
  # Save visit in Datastore
  visit = dataset.entity "Visit"
  visit["user_ip"]   = Digest::SHA256.hexdigest request.ip
  visit["timestamp"] = Time.now
  dataset.save visit

  # Query the last 10 visits from the Datastore
  query  = dataset.query("Visit").order("timestamp", :desc).limit(10)
  visits = dataset.run query

  response.write "Last 10 visits:\n"

  visits.each do |visit|
    response.write "Time: #{visit['timestamp']} Addr: #{visit['user_ip']}\n"
  end

  content_type "text/plain"
  status 200
end
#[END all]
