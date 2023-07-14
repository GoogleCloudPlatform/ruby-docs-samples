# Google App Engine Ruby Samples

These are samples for using Ruby on Google App Engine.
They are referenced from the [docs](https://cloud.google.com/appengine/docs).

See our other [Google Cloud Platform github repos](https://github.com/GoogleCloudPlatform)
for sample applications and scaffolding for other frameworks and use cases.

## Run Locally

Some samples have specific instructions. If there is a README in the sample
folder, please refer to it for any additional steps required to run the sample.

In general, the samples typically require:

1. Install the [Google Cloud SDK](https://cloud.google.com/sdk/), including the
[gcloud tool](https://cloud.google.com/sdk/gcloud/), and
[gcloud app component](https://cloud.google.com/sdk/gcloud-app).
1. Setup the gcloud tool. This provides authentication to Google Cloud APIs and
services.

        gcloud init

1. Clone this repo.

        git clone https://github.com/GoogleCloudPlatform/ruby-docs-samples.git

1. Open a sample folder, install dependencies, and run the sample:

        cd appengine/<sample-folder>/
        bundle install
        bundle exec ruby app.rb -p 8080

1. Visit the application at [http://localhost:8080](http://localhost:8080).

## Deploying

Some samples in this repositories may have special deployment instructions.
Refer to the README file in the sample folder.

1. Use the [Google Developers Console](https://console.developer.google.com) to
create a project/app id. (App id and project id are identical.)
1. Setup the gcloud tool, if you haven't already.

        gcloud init

1. Use gcloud to deploy your app.

        gcloud app deploy

1. Awesome! Your application is now live at `your-app-id.appspot.com`.

## Testing

You must install/configure `gcloud` (above) and set the following environment
variables to run most tests in this directory:

  * `E2E`: Enable end-to-end testing.
  * `TEST_DIR`: This is the relative path of the directory you're testing (e.g. `appengine/analytics`).
  * `BUILD_ID`: A unique ID for deployments.
  * `GOOGLE_APPLICATION_CREDENTIALS`: Path to credentials json file
  * `E2E_GOOGLE_CLOUD_PROJECT`: Project ID to deploy

Then run:

```bash
bundle install && bundle exec rspec --format documentation
```
