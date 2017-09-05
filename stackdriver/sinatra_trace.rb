require "sinatra"

# [START trace_configure]
require "google/cloud/trace"

Google::Cloud.configure do |config|
  # Stackdriver Trace specific parameters
  config.trace.project_id = "YOUR-PROJECT-ID"
  config.trace.keyfile    = "/path/to/service-account.json"
end
# [END trace_configure]

# [START trace_middleware]
require "google/cloud/trace"

use Google::Cloud::Trace::Middleware
# [END trace_middleware]

get "/" do
  "hello world"
end

get "/trace" do
# [START trace_custom_span]
  Google::Cloud::Trace.in_span "my_task" do |span|
    # Insert task

    Google::Cloud::Trace.in_span "my_subtask" do |subspan|
      # Insert subtask
    end
  end
# [END trace_custom_span]
end
