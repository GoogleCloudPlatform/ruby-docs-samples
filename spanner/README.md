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
      create_database                    <instance_id> <database_id> Create Database
      create_table_with_timestamp_column <instance_id> <database_id> Create table Performances with commit timestamp column
      insert_data                        <instance_id> <database_id> Insert Data
      insert_data_with_timestamp_column  <instance_id> <database_id> Inserts data into Performances table containing the commit timestamp column
      query_data                         <instance_id> <database_id> Query Data
      read_data                          <instance_id> <database_id> Read Data
      read_stale_data                    <instance_id> <database_id> Read Stale Data
      create_index                       <instance_id> <database_id> Create Index
      create_storing_index               <instance_id> <database_id> Create Storing Index
      add_column                         <instance_id> <database_id> Add Column
      add_timestamp_column               <instance_id> <database_id> Alters existing Albums table, adding a commit timestamp column
      update_data                        <instance_id> <database_id> Update Data
      update_data_with_timestamp_column  <instance_id> <database_id> Updates two records in the altered table where the commit timestamp column was added
      query_data_with_new_column         <instance_id> <database_id> Query Data with New Column
      query_data_with_timestamp_column   <instance_id> <database_id> Queries data from altered table where the commit timestamp column was added
      write_struct_data                  <instance_id> <database_id> Inserts sample data that can be used for STRUCT queries
      query_with_struct                  <instance_id> <database_id> Queries data using a STRUCT parameter
      query_with_array_of_struct         <instance_id> <database_id> Queries data using an array of STRUCT values as parameter
      query_struct_field                 <instance_id> <database_id> Queries data by accessing field from a STRUCT parameter
      query_nested_struct_field          <instance_id> <database_id> Queries data by accessing field from nested STRUCT parameters
      query_data_with_index              <instance_id> <database_id> <start_title> <end_title> Query Data with Index
      read_write_transaction             <instance_id> <database_id> Read-Write Transaction
      read_data_with_index               <instance_id> <database_id> Read Data with Index
      read_data_with_storing_index       <instance_id> <database_id> Read Data with Storing Index
      read_only_transaction              <instance_id> <database_id> Read-Only Transaction
      spanner_batch_client               <instance_id> <database_id> Use Spanner batch query with a thread pool
      insert_using_dml                   <instance_id> <database_id> Insert Data using a DML statement.
      update_using_dml                   <instance_id> <database_id> Update Data using a DML statement.
      delete_using_dml                   <instance_id> <database_id> Delete Data using a DML statement.
      update_using_dml_with_timestamp    <instance_id> <database_id> Update the timestamp value of specific records using a DML statement.
      write_and_read_using_dml           <instance_id> <database_id> Insert data using a DML statement and then read the inserted data.
      update_using_dml_with_struct       <instance_id> <database_id> Update data using a DML statement combined with a Spanner struct.
      write_using_dml                    <instance_id> <database_id> Insert multiple records using a DML statement.
      query_with_parameter               <instance_id> <database_id> Query record inserted using DML with a query parameter.
      write_with_transaction_using_dml   <instance_id> <database_id> Update data using a DML statement within a read-write transaction.
      update_using_partitioned_dml       <instance_id> <database_id> Update multiple records using a partitioned DML statement.
      delete_using_partitioned_dml       <instance_id> <database_id> Delete multiple records using a partitioned DML statement.
      update_using_batch_dml             <instance_id> <database_id> Updates sample data in the database using Batch DML.
      create_backup                      <instance_id> <database_id> <backup_id> Create a backup.
      restore_backup                     <instance_id> <database_id> <backup_id> Restore a database.
      create_backup_cancel               <instance_id> <database_id> <backup_id> Cancel a backup.
      list_backup_operations             <instance_id> List backup operations.
      list_database_operations           <instance_id> List database operations.
      list_backups                       <instance_id> <backup_id> <database_id> List and filter backups.
      delete_backup                      <instance_id> <backup_id> Delete a backup.
      update_backup                      <instance_id> <backup_id> Update the backup expiry time.
    Environment variables:
      GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID

