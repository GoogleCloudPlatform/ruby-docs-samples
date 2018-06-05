require "google/cloud/firestore"

def delete_collection collection_name:
  firestore = Google::Cloud::Firestore.new project_id: ENV["FIRESTORE_PROJECT_ID"]
  cities_ref = firestore.col collection_name
  query = cities_ref
  query.get do |document_snapshot|
    document_ref = document_snapshot.ref
    document_ref.delete
  end
end

def delete_collection_test collection_name:
  firestore = Google::Cloud::Firestore.new project_id: ENV["GOOGLE_CLOUD_PROJECT"]
  cities_ref = firestore.col collection_name
  query = cities_ref
  query.get do |document_snapshot|
    document_ref = document_snapshot.ref
    document_ref.delete
  end
end