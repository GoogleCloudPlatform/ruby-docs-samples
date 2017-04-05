<img src="https://avatars2.githubusercontent.com/u/2810941?v=3&s=96" alt="Google Cloud Platform logo" title="Google Cloud Platform" align="right" height="96" width="96"/>

# Google Cloud Storage Ruby Samples

[Cloud Storage][storage_docs] allows world-wide storage and retrieval of any
amount of data at any time.

[storage_docs]: https://cloud.google.com/storage/docs/

## Run sample

To run the sample, first install dependencies:

    bundle install

Run the sample:

    bundle exec ruby buckets.rb
    bundle exec ruby files.rb

## Samples

### Buckets

**Usage:** `bundle exec ruby buckets.rb [command] [arguments]`

```
sage: bundle exec ruby buckets.rb [command] [arguments]

Commands:
  list               List all buckets in the authenticated project
  create <bucket>    Create a new bucket with the provided name
  delete <bucket>    Delete bucket with the provided name

Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
```

### Files

**Usage:** `bundle exec ruby files.rb [command] [arguments]`

```
Usage: bundle exec ruby files.rb [command] [arguments]

Commands:
  list              <bucket>                                        List all files in the bucket
  upload            <bucket> <file>                                 Upload local file to a bucket
  encrypted_upload  <bucket> <file> <base64_encryption_key>         Upload local file as an encrypted file to a bucket
  download           <bucket> <file> <path>                         Download a file from a bucket
  encrypted_download <bucket> <file> <path> <base64_encryption_key> Download an encrypted file from a bucket
  rotate_encryption_key <bucket> <file> <base64_current_encryption_key> <base64_new_encryption_key> Update encryption key of an encrypted file.
  generate_encryption_key                                           Generate a sample encryption key
  delete       <bucket> <file>                                      Delete a file from a bucket
  metadata     <bucket> <file>                                      Display metadata for a file in a bucket
  make_public  <bucket> <file>                                      Make a file in a bucket public
  rename       <bucket> <file> <new>                                Rename a file in a bucket
  copy <srcBucket> <srcFile> <destBucket> <destFile>                Copy file to other bucket
  generate_signed_url <bucket> <file>                               Generate a signed url for a file

Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
```
