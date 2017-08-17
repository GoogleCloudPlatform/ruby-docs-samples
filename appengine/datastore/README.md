# App Engine Flexible Environment - Cloud Datastore Sample

## Application code

The sample application logs, retrieves, and displays visitor IPs. You
can see that a visit is a Cloud Datastore entity of kind `Visit`, and
is saved using the Dataset `save` method. Then, the ten most recent
visits are retrieved in descending order by building a Query, and
using the Dataset `run` method.

## Run Locally

1. Make sure `gcloud` is installed. 
2. Start the Datastore emulator.

```
gcloud beta emulators datastore start
```

3. Set the environment.

```
$(gcloud beta emulators datastore env-init)
```

4. Run the sample.

```
bundle install
bundle exec ruby app.rb -p 8080
```

5. Visit the application at [http://localhost:8080/](http://localhost:8080/)

## Run Using Cloud Datastore

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
