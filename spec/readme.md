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
1. Create the `appengine/cloudsql-mysql` and `appengine/cloudsql-postgres` tables.
   `cloud-samples-ruby-test-kokoro` has one Mysql instance, one Postgres instance,
   and tables `cloud_samples_ruby_test_{0..9}`. This way, we can save costs by
   only running CloudSQL in a single project, but keep project data independent.
   First, set the variables referenced in the `create_tables.rb` files, then run:

    ```bash
    cd appengine/cloudsql-mysql
    for i in {0..9}; do
        export MYSQL_DATABASE=cloud_samples_ruby_test_$i
        bundle exec ruby create_tables.rb
    end
    cd ../appengine/cloudsql-postgres
    for i in {0..9}; do
        export POSTGRES_DATABASE=cloud_samples_ruby_test_$i
        bundle exec ruby create_tables.rb
    end
    ```

## Creating the Kokoro service account

for i in {0..9}; do
    gcloud config set project cloud-samples-ruby-test-$i

    gcloud iam service-accounts create kokoro-cloud-samples-ruby-$i --display-name "Kokoro Ruby $i"
    gcloud iam service-accounts keys create kokoro-cloud-samples-ruby-test-$i.json --iam-account kokoro-cloud-samples-ruby-$i@cloud-samples-ruby-test-$i.iam.gserviceaccount.com

    gcloud projects add-iam-policy-binding cloud-samples-ruby-test-$i --member serviceAccount:kokoro-cloud-samples-ruby-$i@cloud-samples-ruby-test-$i.iam.gserviceaccount.com --role roles/owner
    gcloud projects add-iam-policy-binding cloud-samples-ruby-test-$i --member serviceAccount:kokoro-cloud-samples-ruby-$i@cloud-samples-ruby-test-$i.iam.gserviceaccount.com --role roles/cloudkms.cryptoKeyEncrypterDecrypter

    # Every service account should have access to the main project, the 0
    # project (for Spanner), and the 1 project (for Stackdriver).
    gcloud projects add-iam-policy-binding cloud-samples-ruby-test-kokoro --member serviceAccount:kokoro-cloud-samples-ruby-$i@cloud-samples-ruby-test-$i.iam.gserviceaccount.com --role roles/owner
    gcloud projects add-iam-policy-binding cloud-samples-ruby-test-0 --member serviceAccount:kokoro-cloud-samples-ruby-$i@cloud-samples-ruby-test-$i.iam.gserviceaccount.com --role roles/owner
    gcloud projects add-iam-policy-binding cloud-samples-ruby-test-1 --member serviceAccount:kokoro-cloud-samples-ruby-$i@cloud-samples-ruby-test-$i.iam.gserviceaccount.com --role roles/owner

    # Every project should have access to the Firebase project.
    gcloud projects add-iam-policy-binding ruby-firestore-ci --member serviceAccount:kokoro-cloud-samples-ruby-$i@cloud-samples-ruby-test-$i.iam.gserviceaccount.com --role roles/owner
done