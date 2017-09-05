# [START explicit_debugger_ruby]
require "google/cloud/debugger"

Google::Cloud::Debugger.new(project_id: "YOUR-PROJECT-ID",
                            keyfile:    "/path/to/service-account.json").start
# [END explicit_debugger_ruby]

# [START implicit_debugger_ruby]
require "google/cloud/debugger"

Google::Cloud::Debugger.new.start
# [END implicit_debugger_ruby]

