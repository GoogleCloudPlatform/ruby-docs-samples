

for i in {0..9}; do
    ./gimmeproj -project=cloud-samples-ruby-test-kokoro pool-add cloud-samples-ruby-test-$i

    gcloud config set project cloud-samples-ruby-test-$i

    gcloud iam service-accounts create test-account

    gcloud datastore create-indexes index.yaml

    gcloud iam service-accounts create kokoro
    gcloud projects add-iam-policy-binding cloud-samples-ruby-test-$i --member "serviceAccount:kokoro@cloud-samples-ruby-test-$i.iam.gserviceaccount.com" --role "roles/owner"
    gcloud iam service-accounts keys create cloud-samples-ruby-test-$i-service-account.json --iam-account kokoro@cloud-samples-ruby-test-$i.iam.gserviceaccount.com
done