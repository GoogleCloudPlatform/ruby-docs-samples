# App Engine Flexible Environment - Pub/Sub Sample

## Clone the sample app

Copy the sample apps to your local machine, and cd to the pubsub directory:

```
git clone https://github.com/GoogleCloudPlatform/ruby-docs-samples
cd ruby-docs-samples/appengine/pubsub
```

## Create a topic and subscription

Create a topic and subscription, which includes specifying the
endpoint to which the Pub/Sub server should send requests:

```
gcloud beta pubsub topics create <your-topic-name>
gcloud beta pubsub subscriptions create <your-subscription-name> \
  --topic <your-topic-name> \
  --push-endpoint \
  https://<your-project-id>.appspot.com/pubsub/push?token=<your-token> \
  --ack-deadline 30
```



## Run

Make sure `gcloud` is installed and authenticated. You can find your
project id with `gcloud config list`. The token should be any random
string.

```
export PUBSUB_VERIFICATION_TOKEN=<your-token>
export PUBSUB_TOPIC=<your-topic-name>
export GOOGLE_CLOUD_PROJECT=<your-project-id>
bundle
bundle exec ruby app.rb
```

visit on `http://localhost:4567/`

send fake push messages with:

```
curl -i --data @sample_message.json "localhost:4567/pubsub/push?token=<your-token>"
```


## Deploy

To deploy to the App Engine **standard environment**, put topic and token in `app.standard.yaml`, then:

```
gcloud app deploy app.standard.yaml
```

To deploy to the App Engine **flexible environment**, put topic and token in `app.yaml`, then:

```
gcloud app deploy app.yaml
```


## Test

Note: the tests do a live deploy to App Engine

Put a `client_secrets.json` file for a service account in the root of
your repo.

```
gcloud auth activate-service-account --key-file ../../client_secrets.json
export GOOGLE_CLOUD_PROJECT=<your-project-id>
export TEST_DIR=appengine/pubsub/
bundle exec rspec
```
