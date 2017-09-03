require "sinatra"

get "/" do

end

get "/raise" do
# [START error_reporting_exception]
  require "google/cloud/error_reporting"

  begin
    fail "Raise an exception for Error Reporting."
  rescue => exception
    Google::Cloud::ErrorReporting.report exception
  end
# [END error_reporting_exception]
end

