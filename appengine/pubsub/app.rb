require "sinatra"
require "slim"
require "json"
require "base64"
require "gcloud"

PUBSUB_VERIFICATION_TOKEN = ENV["PUBSUB_VERIFICATION_TOKEN"]

gcloud = Gcloud.new
pubsub = gcloud.pubsub
topic  = pubsub.topic ENV["PUBSUB_TOPIC"]

# List of all messages received by this instance
messages = []

get "/" do
  @messages = messages

  slim :index
end

post "/publish" do
  topic.publish params[:payload]

  redirect "/"
end

post "/pubsub/push" do
  halt 400 if params[:token] != PUBSUB_VERIFICATION_TOKEN

  message = JSON.parse request.body.read
  payload = Base64.decode64 message["message"]["data"]

  messages.push payload
end

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
