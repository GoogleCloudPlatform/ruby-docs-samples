# Google Cloud Endpoints & App Engine Flexible Environment & Ruby

This sample demonstrates how to use Google Cloud Endpoints on
Google App Engine flexible environment using Ruby. This sample requires that you
have [Ruby](https://www.ruby-lang.org/en/documentation/installation/) 2.0.0 or
newer installed.

This sample consists of two parts:

1. The backend
2. The clients

## Running locally

### Running the backend

Install all the dependencies:

    $ bundle install

Run the application:

    $ bundle exec ruby app.rb -p 8080

### Using the echo client

With the app running locally, you can execute the simple echo client using:

    $ bundle exec ruby clients/echo_client.rb \
        --host http://localhost:8080 \
        --api_key APIKEY \
        --message "message to echo"

The `APIKEY` doesn't matter as the endpoint proxy is not running to do authentication.

## Deploying to Google App Engine

Open the `openapi.yaml` file and in the `host` property, replace
`YOUR-PROJECT-ID` with your project's ID.

Then, deploy the sample using `gcloud`:

    gcloud beta app deploy

Once deployed, you can access the application at https://YOUR-PROJECT-ID.appspot.com/.

### Using the echo client

With the project deployed, you'll need to create an API key to access the API.

1. Open the Credentials page of the API Manager in the [Cloud Console](https://console.cloud.google.com/apis/credentials).
2. Click 'Create credentials'.
3. Select 'API Key'.
4. Choose 'Server Key'

With the API key, you can use the echo client to access the API:

    $ bundle exec ruby clients/echo_client.rb \
        --host https://YOUR-PROJECT-ID.appspot.com \
        --api_key YOUR-API-KEY \
        --message "message to echo"

### Using the JWT client.

The JWT client demonstrates how to use service accounts to authenticate to endpoints. To use the client, you'll need both an API key (as described in the echo client section) and a service account. To create a service account:

1. Open the Credentials page of the API Manager in the [Cloud Console](https://console.cloud.google.com/apis/credentials).
2. Click 'Create credentials'.
3. Select 'Service account key'.
4. In the 'Select service account' dropdown, select 'Create new service account'.
5. Choose 'JSON' for the key type.

To use the service account for authentication:

1. Update the `google_jwt`'s `x-jwks_uri` in `openapi.yaml` with your service account's email address.
2. Redeploy your application.

Now you can use the JWT client to make requests to the API:

    $ bundle exec ruby clients/google_jwt_client.rb \
        --host https://YOUR-PROJECT-ID.appspot.com \
        --api_key YOUR-API-KEY \
        --service_account_file /path/to/service-account.json

### Using the ID Token client.

The ID Token client demonstrates how to use user credentials to authenticate to endpoints. To use the client, you'll need both an API key (as described in the echo client section) and a OAuth2 client ID. To create a client ID:

1. Open the Credentials page of the API Manager in the [Cloud Console](https://console.cloud.google.com/apis/credentials).
2. Click 'Create credentials'.
3. Select 'OAuth client ID'.
4. Choose 'Other' for the application type.

To use the client ID for authentication:

1. Update the `/auth/info/googleidtoken`'s `audiences` in `openapi.yaml` with your client ID.
2. Redeploy your application.

Now you can use the client ID to make requests to the API:

    $ bundle exec ruby clients/google_id_token_client.rb \
        --host https://YOUR-PROJECT-ID.appspot.com \
        --api_key YOUR-API-KEY \
        --client_secrets_file /path/to/client_secrets.json

## Viewing the Endpoints graphs

By using Endpoints, you get access to several metrics that are displayed graphically in the Cloud Console.

To view the Endpoints graphs:

1. Go to the [Endpoints section in Cloud Console](https://console.cloud.google.com/endpoints) of the project you deployed your API to.
2. Click on your API to view more detailed information about the metrics collected.

## Swagger UI

The Swagger UI is an open source Swagger project that allows you to explore your API through a UI. Find out more about it on the [Swagger site](http://swagger.io/swagger-ui/).
