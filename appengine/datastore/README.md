# App Engine Flexible Environment - Cloud Datastore Sample

## Application code

The sample application logs, retrieves, and displays visitor IPs. You
can see that a visit is a Cloud Datastore entity of kind `Visit`, and
is saved using the Dataset `save` method. Then, the ten most recent
visits are retrieved in descending order by building a Query, and
using the Dataset `run` method.

## Run

Make sure `gcloud` is installed and authenticated. You can find your
project id with `gcloud config list`.


```
export GOOGLE_CLOUD_PROJECT=<your-project-id>
bundle
bundle exec ruby ./app.rb
```

## Deploy

```
gcloud app deploy
```

## Test

Note: the tests do a live deploy to App Engine

Put a `client_secrets.json` file for a service account in the root of
your repo.

```
gcloud auth activate-service-account --key-file ../../client_secrets.json
export TEST_DIR=appengine/datastore/
bundle exec rspec
```
