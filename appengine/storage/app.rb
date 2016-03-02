require "sinatra"
require "gcloud"

gcloud  = Gcloud.new
storage = gcloud.storage
bucket  = storage.bucket ENV["CLOUD_STORAGE_BUCKET"]

get "/" do
  # Present the user with an upload form
  %{
    <form method="POST" action="/upload" enctype="multipart/form-data">
      <input type="file" name="file">
      <input type="submit">
    </form>
  }
end

post "/upload" do
  # Upload file to Google Cloud Storage bucket
  file = bucket.create_file params[:file][:tempfile].path,
                            params[:file][:filename],
                            acl: "public"

  # The public URL can be used to directly access the uploaded file via HTTP
  file.public_url
end
