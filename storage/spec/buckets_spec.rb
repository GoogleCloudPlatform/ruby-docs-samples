require_relative "../buckets"
require "rspec"
require "google/cloud"

RSpec.describe "Google Cloud Storage bucket management" do

  before :all do
    @project_id  = ENV["GOOGLE_PROJECT_ID"]
    @bucket_name = ENV["STORAGE_BUCKET"]
    @gcloud      = Google::Cloud.new @project_id
    @storage     = @gcloud.storage
  end

  before do
    @storage.create_bucket @bucket_name unless @storage.bucket @bucket_name
  end

  after :all do
    # Other tests assume that this bucket exists,
    # so create it before exiting this spec suite
    @storage.create_bucket @bucket_name unless @storage.bucket(@bucket_name)
  end

  def delete_bucket!
    bucket = @storage.bucket @bucket_name

    if bucket
      bucket.files.each &:delete until bucket.files.empty?
      bucket.delete
    end
  end

  example "list buckets" do
    expect {
      list_buckets project_id: @project_id
    }.to output(
      /#{@bucket_name}/
    ).to_stdout
  end

  example "create bucket" do
    delete_bucket!

    expect(@storage.bucket @bucket_name).to be nil

    expect {
      create_bucket project_id:  @project_id,
                    bucket_name: @bucket_name
    }.to output(
      "Created bucket: #{@bucket_name}\n"
    ).to_stdout

    expect(@storage.bucket @bucket_name).not_to be nil
  end

  example "delete bucket" do
    expect(@storage.bucket @bucket_name).not_to be nil

    expect {
      delete_bucket project_id: @project_id, bucket_name: @bucket_name
    }.to output(
      "Deleted bucket: #{@bucket_name}\n"
    ).to_stdout

    expect(@storage.bucket @bucket_name).to be nil
  end

end
