<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Spanner Ruby Samples

The [Google Cloud Spanner](https://cloud.google.com/spanner/) is a fully
managed, mission-critical, relational database service that offers
transactional consistency at global scale, schemas,
SQL (ANSI 2011 with extensions), and automatic, synchronous replication for
high availability.

## Setup

### Authentication

Authentication is typically done through [Application Default Credentials](https://cloud.google.com/docs/authentication#getting_credentials_for_server-centric_flow)
, which means you do not have to change the code to authenticate as long as your
environment has credentials. You have a few options for setting up
authentication:

1. When running locally, use the [Google Cloud SDK](https://cloud.google.com/sdk/)

    `gcloud auth application-default login`

1. When running on App Engine or Compute Engine, credentials are already set-up.
However, you may need to configure your Compute Engine instance with
[additional scopes](https://cloud.google.com/compute/docs/authentication#using).

1. You can create a [Service Account key file](https://cloud.google.com/docs/authentication#service_accounts)
. This file can be used to authenticate to Google Cloud Platform services from
any environment. To use the file, set the `GOOGLE_APPLICATION_CREDENTIALS`
environment variable to the path to the key file, for example:

    `export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service_account.json`

### Install Dependencies

1. Install the [Bundler](http://bundler.io/) gem.

1. Install dependencies using:

    `bundle install`

## Run Quickstart

    bundle exec ruby quickstart.rb

## Run the samples

    Usage: bundle exec ruby spanner_samples.rb [command] [arguments]

    Commands:
      create_database              <instance_id> <database_id> Create Database
      insert_data                  <instance_id> <database_id> Insert Data
      query_data                   <instance_id> <database_id> Query Data
      read_data                    <instance_id> <database_id> Read Data
      read_stale_data              <instance_id> <database_id> Read Stale Data
      create_index                 <instance_id> <database_id> Create Index
      create_storing_index         <instance_id> <database_id> Create Storing Index
      add_column                   <instance_id> <database_id> Add Column
      update_data                  <instance_id> <database_id> Update Data
      query_data_with_new_column   <instance_id> <database_id> Query Data with New Column
      read_write_transaction       <instance_id> <database_id> Read-Write Transaction
      read_data_with_index         <instance_id> <database_id> <start_title> <end_title> Query Data with Index
      read_data_with_index         <instance_id> <database_id> Read Data with Index
      read_data_with_storing_index <instance_id> <database_id> Read Data with Storing Index
      read_only_transaction        <instance_id> <database_id> Read-Only Transaction

    Environment variables:
      GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
