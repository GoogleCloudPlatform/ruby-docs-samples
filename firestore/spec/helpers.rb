require "google/cloud/firestore"

def delete_collection_test collection_name:, project_id:
  firestore = Google::Cloud::Firestore.new project_id: project_id
  cities_ref = firestore.col collection_name
  query = cities_ref
  query.get do |document_snapshot|
    document_ref = document_snapshot.ref
    document_ref.delete
  end
end
