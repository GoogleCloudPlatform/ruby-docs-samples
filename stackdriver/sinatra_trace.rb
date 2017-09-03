require "sinatra"

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
