# Cloud Run Hello World Sample

This sample shows how to deploy a Hello World application to Cloud Run.

[![Run in Google Cloud][run_img]][run_link]

[run_img]: https://storage.googleapis.com/cloudrun/button.svg
[run_link]: https://console.cloud.google.com/cloudshell/editor?shellonly=true&cloudshell_image=gcr.io/cloudrun/button&cloudshell_git_repo=https://github.com/GoogleCloudPlatform/ruby-docs-samples&cloudshell_working_dir=run/helloworld

## Setup

1. [Set up for Cloud Run development](https://cloud.google.com/run/docs/setup)

1. Clone this repository:

    ```sh
    git clone https://github.com/GoogleCloudPlatform/ruby-docs-samples.git
    ```
1. Create an Artifact Registry:

    ```sh
    gcloud artifacts repositories create containers --repository-format docker --location ${GOOGLE_CLOUD_REGION}
    ```

## Build

```
docker build --tag helloworld:ruby .
```

## Run Locally

```
docker run --rm -p 9090:8080 -e PORT=8080 helloworld:ruby
```

## Test

```sh
# Set an environment variable with your GCP Project ID
export GOOGLE_CLOUD_PROJECT=<PROJECT_ID>

# Install dependencies
bundle install

# Run tests
bundle exec rspec
```

## Deploy

```sh
# Set an environment variable with your GCP Project ID
export GOOGLE_CLOUD_PROJECT=<PROJECT_ID>

# Set an environment variable with your Google Cloud region
export GOOGLE_CLOUD_REGION=<REGION>

# Submit a build using Google Cloud Build
gcloud builds submit --tag ${GOOGLE_CLOUD_REGION}-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/containers/helloworld

# Deploy to Cloud Run
gcloud run deploy helloworld --image ${GOOGLE_CLOUD_REGION}-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/containers/helloworld
```

Visit your deployed container by opening the service URL in a web browser.
