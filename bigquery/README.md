<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google BigQuery API Ruby Samples

[BigQuery][bigquery_docs] is Google's fully managed, petabyte scale, low cost
analytics data warehouse.

[bigquery_docs]: https://cloud.google.com/bigquery/docs/

## Samples

### Datasets

```
Usage: ruby datasets.rb <command> [arguments]

Commands:
  create <dataset_id>   Create a new dataset with the specified ID
  list                  List datasets in the specified project
  delete <dataset_id>   Delete the dataset with the specified ID
```

### Tables

```
Usage: ruby tables.rb <command> [arguments]

Commands:
  create      <dataset_id> <table_id>  Create a new table with the specified ID
  list        <dataset_id>             List all tables in the specified dataset
  delete      <dataset_id> <table_id>  Delete table with the specified ID
  list_data   <dataset_id> <table_id>  List data in table with the specified ID
  import_file <dataset_id> <table_id> <file_path>
  import_gcs  <dataset_id> <table_id> <cloud_storage_path>
  export      <dataset_id> <table_id> <cloud_storage_path>
  query       <query>
  query_job   <query>
```

