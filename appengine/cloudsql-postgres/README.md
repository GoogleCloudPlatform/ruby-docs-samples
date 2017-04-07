# Ruby Cloud SQL PostgreSQL sample on Google App Engine flexible environment

This sample demonstrates how to use
[Google Cloud SQL for PostgreSQL][postgres]
(or any other SQL server) on [Google App Engine flexible environment][flexible].

## Setup

Before you can run or deploy the sample, you will need to do the following:

 1. [Create a Cloud SQL for PostgreSQL instance](https://cloud.google.com/sql/docs/postgres/create-instance).

 2. If you haven't already, set the password for the default user on your Cloud SQL instance:

        gcloud beta sql users set-password postgres no-host \
          --instance [INSTANCE_NAME] --password [PASSWORD]

 2. Record the connection name for the instance:

        gcloud sql instances describe [INSTANCE_NAME]

    For example:

        connectionName: project1:us-central1:instance1

    You can also find this value in the **Instance overview** page of the Google Cloud Platform Console.

 1. Create a [Service Account][service] for your project. You will use this
service account to connect to your Cloud SQL instance locally.

 1. Download and install the [Cloud SQL Proxy][proxy].

 1. [Start the proxy][start] to allow connecting to your instance from your local
machine:

        cloud_sql_proxy \
            -dir /cloudsql \
            -instances=[YOUR_INSTANCE_CONNECTION_NAME] \
            -credential_file=PATH_TO_YOUR_SERVICE_ACCOUNT_JSON

    where `[YOUR_INSTANCE_CONNECTION_NAME]` is the connection name of your
    instance on its Overview page in the Google Cloud Platform Console.

 1. Set the `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_SOCKET_PATH`, and
`POSTGRES_DATABASE` environment variables. This allows the app to connect to your
Cloud SQL instance through the proxy.

 1. Update the values in `app.yaml` with your instance configuration.

 1. Install dependencies

    bundle install

1. Finally, run `create_tables.rb` to ensure that the database is properly
configured and to create the tables needed for the sample.

## Running locally

Refer to the [top-level README](../README.md) for instructions on running and deploying.

It's recommended to follow the instructions above to run the Cloud SQL proxy.
You will need to set the following environment variables via your shell before
running the sample:

    export POSTGRES_USER="YOUR_USER"
    export POSTGRES_PASSWORD="YOUR_PASSWORD"
    export POSTGRES_SOCKET_PATH="YOUR_SOCKET_PATH"
    export POSTGRES_DATABASE="YOUR_DATABASE"
    bundle install
    bundle exec ruby create_tables.rb
    bundle exec ruby app.rb

[postgres]: https://cloud.google.com/sql/docs/postgres/
[flexible]: https://cloud.google.com/appengine
[gen]: https://cloud.google.com/sql/docs/create-instance
[console]: https://console.developers.google.com
[sdk]: https://cloud.google.com/sdk
[service]: https://cloud.google.com/sql/docs/external#createServiceAccount
[proxy]: https://cloud.google.com/sql/docs/external#install
[start]: https://cloud.google.com/sql/docs/external#6_start_the_proxy
[user]: https://cloud.google.com/sql/docs/create-user
[database]: https://cloud.google.com/sql/docs/create-database
