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

  Net::HTTP.post_form URI("http://www.google-analytics.com/collect"),
    v: "1",               # API Version
    tid: GA_TRACKING_ID,  # Tracking ID / Property ID
    cid: client_id,       # Client ID
    t: "event",           # Event hit type
    ec: category,         # Event category
    ea: action,           # Event action
    el: label,            # Event label
    ev: value             # Event value
end

get "/" do
  track_event "Example category", "Example action", "Example label", "123"

  "Event tracked."
end
