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
  query  = dataset.query("Visit").order("timestamp", :desc)
  visits = dataset.run query

  response.write "Last 10 visits:\n"

  visits.each do |visit|
    response.write "Time: #{visit["timestamp"]} Addr: #{visit["user_ip"]}\n"
  end

  content_type "text/plain"
  status 200
end
