require_relative "helper"
require_relative "../quickstart.rb"

describe "Storage Quickstart" do
  let(:storage_client) { Google::Cloud::Storage.new }
  let(:bucket_name)    { "ruby_storage_sample_#{SecureRandom.hex}" }

  after do
    delete_bucket_helper bucket_name
  end

  it "creates a new bucket" do
    assert_output "Bucket #{bucket_name} was created.\n" do
      quickstart bucket_name: bucket_name
    end

    assert storage_client.bucket bucket_name
  end
end
