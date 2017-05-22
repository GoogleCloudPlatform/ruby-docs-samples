<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# BigQuery Ruby Samples

[![Build](https://storage.googleapis.com/cloud-docs-samples-badges/GoogleCloudPlatform/ruby-docs-samples/bigquery.svg)]()

[BigQuery](https://cloud.google.com/bigquery/docs) is Google&#x27;s fully managed, petabyte scale, low cost analytics data warehouse.

## Table of Contents

* [Setup](#setup)
* [Samples](#samples)
  * [Datasets](#datasets)
  * [Tables](#tables)
* [Running the tests](#running-the-tests)

## Setup

1.  Read [Prerequisites][prereq] and [How to run a sample][run] first.
1.  Install dependencies:

        bundle install

[prereq]: ../README.md#prerequisities
[run]: ../README.md#how-to-run-a-sample

## Samples

### Datasets


View the [documentation][datasets_0_docs] or the [source code][datasets_0_code].

__Usage:__ `ruby datasets.rb --help`

```
Usage: ruby datasets.rb <command> [arguments]

Commands:
  create <dataset_id>   Create a new dataset with the specified ID
  list                  List datasets in the specified project
  delete <dataset_id>   Delete the dataset with the specified ID
```

[datasets_0_docs]: https://cloud.google.com/bigquery/docs
[datasets_0_code]: datasets.rb

### Tables


View the [documentation][tables_1_docs] or the [source code][tables_1_code].

__Usage:__ `ruby tables.rb --help`

```
Usage: ruby tables.rb <command> [arguments]

Commands:
  create      <dataset_id> <table_id>  Create a new table with the specified ID
  list        <dataset_id>             List all tables in the specified dataset
  delete      <dataset_id> <table_id>  Delete table with the specified ID
  list_data   <dataset_id> <table_id>  List data in table with the specified ID
  import_file <dataset_id> <table_id> <file_path>
  import_gcs  <dataset_id> <table_id> <cloud_storage_path>
  import_data <dataset_id> <table_id> "[{ <json row data> }]"
  export      <dataset_id> <table_id> <cloud_storage_path>
  query       <query>
  query_job   <query>
```

[tables_1_docs]: https://cloud.google.com/bigquery/docs
[tables_1_code]: tables.rb

## Running the tests

1.  Set the **GCLOUD_PROJECT** and **GOOGLE_APPLICATION_CREDENTIALS** environment variables.

1.  Run the tests:

        bundle exec rspec
