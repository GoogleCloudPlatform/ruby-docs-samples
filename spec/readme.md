# Testing

Tests are run using a pool of projects to avoid race conditions between projects.

The "parent" of the pool is `cloud-samples-ruby-test-kokoro`. It keeps the list of
available projects and is charged quota for most projects. Tests are run as
`cloud-samples-ruby-test-{0..9}`. New projects should follow the numbering convention.

To set up an account:

1. Get `copyproj.sh` and `gimmeproj` from
   https://github.com/GoogleCloudPlatform/golang-samples/tree/master/testing/gimmeproj.
1. Create the projects.
1. Run the following commands (wrapped in a for loop to make it easy):
    ```bash
    for i in {0..9}; do
        ./copyproj.sh cloud-samples-ruby-test-kokoro cloud-samples-ruby-test-$i
        ./gimmeproj -project=cloud-samples-ruby-test-kokoro pool-add cloud-samples-ruby-test-$i
        gcloud config set project cloud-samples-ruby-test-$i
        gcloud iam service-accounts create test-account
        gcloud datastore create-indexes index.yaml
    done
    ```
1. The storage service account needs KMS permissions. Follow
   https://cloud.google.com/storage/docs/encryption/using-customer-managed-keys.
