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
    bundle exec ruby acls.rb

## Samples

### Buckets

**Usage:** `bundle exec ruby buckets.rb [command] [arguments]`

```
sage: bundle exec ruby buckets.rb [command] [arguments]

Commands:
  list                            List all buckets in the authenticated project
  enable_requester_pays  <bucket> Enable requester pays for a bucket
  disable_requester_pays <bucket> Disable requester pays for a bucket
  check_requester_pays   <bucket> Check status of requester pays for a bucket
  create                 <bucket> Create a new bucket with the provided name
  delete                 <bucket> Delete bucket with the provided name

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
  download_with_requester_pays <project> <bucket> <file> <path>     Download a file from a requester pays enabled bucket
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

### Access Control List

**Usage:** `bundle exec ruby acls.rb [command] [arguments]`

```
Usage: bundle exec ruby acls.rb [command] [arguments]

Commands:
  print_bucket_acl <bucket>                  Print bucket Access Control List
  print_bucket_acl_for_user <bucket> <email> Print bucket ACL for an email
  add_bucket_owner <bucket> <email>          Add a new OWNER to a bucket
  remove_bucket_acl <bucket> <email>         Remove an entity from a bucket ACL
  add_bucket_default_owner <bucket> <email>  Add a default OWNER for a bucket
  remove_bucket_default_acl <bucket> <email> Remove an entity from default bucket ACL
  print_file_acl <bucket> <file>             Print file ACL
  print_file_acl_for_user <bucket> <file> <email> Print file ACL for an email
  add_file_owner <bucket> <file> <email>          Add an OWNER to a file
  remove_file_acl <bucket> <file> <email>         Remove an entity from a file ACL

Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
```

### Cloud Storage Bucket-level Identity & Access Management

**Usage:** `bundle exec ruby iam.rb [command] [arguments]

```
Usage: bundle exec ruby iam.rb [command] [arguments]

Commands:
  view_bucket_iam_members  <bucket>                         View bucket-level IAM members
  add_bucket_iam_member    <bucket> <iam_role> <iam_member> Add a bucket-level IAM member
  remove_bucket_iam_member <bucket> <iam_role> <iam_member> Remove a bucket-level IAM member

Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
```

