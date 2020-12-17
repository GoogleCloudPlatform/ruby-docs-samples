# App Engine Standard Environment - Cloud Storage Sample

## Clone the sample app

Copy the sample apps to your local machine, and cd to the storage directory:

```
git clone https://github.com/GoogleCloudPlatform/ruby-docs-samples
cd ruby-docs-samples/appengine/standard-storage
```

## Create a bucket

Make sure `gcloud` is installed and authenticated. You can find your
project id with `gcloud config list`.

Create a Cloud Storage bucket for your project:

```
$ gsutil mb gs://<your-project-id>
```

## Run

```
export GOOGLE_CLOUD_PROJECT=<your-project-id>
export GOOGLE_CLOUD_STORAGE_BUCKET=<your-project-id>
bundle
bundle exec ruby app.rb
```

Visit on `http://localhost:4567/`

Choose a file and click "Upload".

The public URL to the uploaded file will be displayed.

## Deploy

Replace `<your-project-id>` and `<your-bucket-name>` in `app.yaml`, then:

```
gcloud app deploy
```

## Test

Note: the tests do a live deploy to App Engine

Put a `client_secrets.json` file for a service account in the root of
your repo.

```
gcloud auth activate-service-account --key-file ../../client_secrets.json
export GOOGLE_CLOUD_PROJECT=<your-project-id>
export TEST_DIR=appengine/storage/
bundle exec rspec
```
