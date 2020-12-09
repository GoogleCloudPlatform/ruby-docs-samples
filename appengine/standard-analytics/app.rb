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

# [START gae_standard_analytics_track_event]
require "sinatra"
require "net/http"

# The following environment variable is set by app.yaml when running on GAE,
# but will need to be manually set when running locally. See README.md.
GA_TRACKING_ID = ENV["GA_TRACKING_ID"]

def track_event category, action, label, value
  # Anonymous Client ID.
  # Ideally, this should be a UUID that is associated
  # with particular user, device, or browser instance.
  client_id = "555"

  Net::HTTP.post_form(
    URI("http://www.google-analytics.com/collect"),
    v:   "1",             # API Version
    tid: GA_TRACKING_ID,  # Tracking ID / Property ID
    cid: client_id,       # Client ID
    t:   "event",         # Event hit type
    ec:  category,        # Event category
    ea:  action,          # Event action
    el:  label,           # Event label
    ev:  value            # Event value
  )
end

get "/" do
  track_event "Example category", "Example action", "Example label", "123"

  "Event tracked."
end
# [END gae_standard_analytics_track_event]
