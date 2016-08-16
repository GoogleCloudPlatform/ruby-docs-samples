# Copyright 2016 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "../sample"
require "rspec"
require "gcloud"
require "net/http"
require "tempfile"

describe "Google Cloud Storage sample" do

  # Returns the text content of a given Gcloud storage object
  def content_of storage_object
    temp_file = Tempfile.new
    storage_object.download temp_file.path
    File.read temp_file.path
  end

  # Capture and return STDOUT output by block
  def capture &block
    real_stdout = $stdout
    $stdout = StringIO.new
    block.call
    $stdout.string
  ensure
    $stdout = real_stdout
  end

  # Tests require environment variables:
  #
  #   GCLOUD_PROJECT   ID of your Google Cloud Platform project
  #   BUCKET           Name of Google Cloud Storage bucket to use for tests
  #   ALT_BUCKET       Name of an alternative bucket to also use for tests
  #
  before :all do
    @project_id     = ENV["GCLOUD_PROJECT"]
    @gcloud         = Gcloud.new @project_id
    @storage        = @gcloud.storage
    @bucket         = @storage.bucket ENV["BUCKET"]
    @alt_bucket     = @storage.bucket ENV["ALT_BUCKET"]
    @test_file_path = File.expand_path "test-object.txt", __dir__
  end

  # Sample code uses project ID "my-gcp-project-id" and bucket "my-bucket"
  #
  # Stub calls to Gcloud library to use our test project and storage buckets
  before :each do
    allow(Gcloud).to receive(:new).with("my-project-id").and_return(@gcloud)
    allow(@gcloud).to receive(:storage).and_return(@storage)
    allow(@storage).to receive(:bucket).with("my-bucket-name").
                       and_return(@bucket)
    allow(@storage).to receive(:bucket).with("other-bucket-name").
                       and_return(@alt_bucket)

    # File uploads use the fake path "/path/to/my-file.txt"
    # When samples upload files, upload the spec/test-object.txt
    # file instead for testing
    allow(@bucket).to receive(:create_file).
                      with("/path/to/my-file.txt", "my-file.txt").
                      and_wrap_original do |create_file, file_path, obj_path|
                        create_file.call @test_file_path, obj_path
                      end

    cleanup!
  end

  # Delete files in bucket used for tests
  def cleanup!
    @bucket.file("my-file.txt").delete      if @bucket.file "my-file.txt"
    @bucket.file("renamed-file.txt").delete if @bucket.file "renamed-file.txt"
    @alt_bucket.file("my-file.txt").delete  if @alt_bucket.file "my-file.txt"
  end

  it "create bucket" do
    # Google Cloud Storage bucket IDs are unique
    #
    # To prevent creating unique buckets, this test simply verifies
    # that the correct `#create_bucket` method is called by the sample
    expect(@storage).to receive(:create_bucket).with("my-bucket-name").
                        and_return(@bucket)

    expect { create_bucket }.to output("Created bucket: #{@bucket.name}\n").
                                to_stdout
  end

  it "upload object" do
    expect(@bucket.file "my-file.txt").to be nil

    expect { upload_object }.to output("Uploaded my-file.txt\n").to_stdout

    expect(@bucket.file "my-file.txt").not_to be nil

    expect(content_of @bucket.file("my-file.txt")).to eq(
      "Content of test object\n"
    )
  end

  it "download object" do
    upload_object

    # This sample downloads to the fake path "/path/to/my-file.txt"
    # When the file download method is called, download to a
    # temporary file instead
    uploaded_file = @bucket.file "my-file.txt"
    temp_file     = Tempfile.new

    expect(@bucket).to receive(:file).with("my-file.txt").
                       and_return(uploaded_file)

    expect(uploaded_file).to receive(:download).with("/path/to/my-file.txt").
                             and_wrap_original do |download, path|
                               download.call temp_file.path
                             end

    expect(File.read temp_file).to eq ""

    expect { download_object }.to output("Downloaded my-file.txt\n").to_stdout

    expect(File.read temp_file).to eq "Content of test object\n"
  end

  it "make object public" do
    upload_object
    uploaded_file = @bucket.file "my-file.txt"

    response = Net::HTTP.get_response URI.parse(uploaded_file.public_url)
    expect(response).to be_a Net::HTTPForbidden
    expect(response.code.to_i).to eq 403

    expect { make_object_public }.to output(
      "my-file.txt is publicly accessible at #{uploaded_file.public_url}\n"
    ).to_stdout

    response = Net::HTTP.get_response URI.parse(uploaded_file.public_url)
    expect(response).to be_a Net::HTTPOK
    expect(response.code.to_i).to eq 200
    expect(response.body).to eq "Content of test object\n"
  end

  it "rename object" do
    upload_object

    expect(@bucket.file "my-file.txt").not_to be nil
    expect(@bucket.file "renamed-file.txt").to be nil

    expect { rename_object }.to output(
      "my-file.txt has been renamed to renamed-file.txt\n"
    ).to_stdout

    expect(@bucket.file "my-file.txt").to be nil
    expect(@bucket.file "renamed-file.txt").not_to be nil

    expect(content_of @bucket.file("renamed-file.txt")).to eq(
      "Content of test object\n"
    )
  end

  it "copy object between buckets" do
    upload_object

    expect(@alt_bucket.file "my-file.txt").to be nil

    expect { copy_object_between_buckets }.to output(
      "my-file.txt in #{@bucket.name} copied to " +
      "my-file.txt in #{@alt_bucket.name}\n"
    ).to_stdout

    expect(@alt_bucket.file "my-file.txt").not_to be nil
    expect(content_of @alt_bucket.file("my-file.txt")).to eq(
      "Content of test object\n"
    )
  end

  it "list bucket contents" do
    upload_object

    expect { list_bucket_contents }.to output(/my-file\.txt/).to_stdout
  end

  it "list object details" do
    upload_object
    uploaded_file = @bucket.file "my-file.txt"

    uploaded_file.cache_control       = "Cache-Control:public, max-age=3600"
    uploaded_file.content_disposition = "attachment; filename=my-file.txt"
    uploaded_file.content_language    = "en"
    uploaded_file.metadata            = { foo: "bar" }

    output = capture { list_object_details }
    
    expect(output).to include("Name: my-file.txt")
    expect(output).to include("Bucket: #{@bucket.name}")
    expect(output).to include("Storage class: STANDARD")
    expect(output).to include("ID: #{uploaded_file.id}")
    expect(output).to include("Size: 23 bytes")
    expect(output).to match(/Created: \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
    expect(output).to match(/Updated: \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
    expect(output).to include("Generation: #{uploaded_file.generation}")
    expect(output).to include(
      "Metageneration: #{uploaded_file.metageneration}"
    )
    expect(output).to include("Etag: #{uploaded_file.etag}")
    expect(output).to include("Owners: #{uploaded_file.acl.owners.join ","}")
    expect(output).to include("Crc32c: #{uploaded_file.crc32c}")
    expect(output).to include("md5_hash: #{uploaded_file.md5}")
    expect(output).to include(
      "Cache-control: Cache-Control:public, max-age=3600"
    )
    expect(output).to include("Content-type: text/plain")
    expect(output).to include(
      "Content-disposition: attachment; filename=my-file.txt"
    )
    expect(output).to include("Content-encoding:")
    expect(output).to include("Content-language: en")
    expect(output).to include("Metadata:\n - foo = bar")
  end

  it "delete object" do
    upload_object

    expect(@bucket.file "my-file.txt").not_to be nil

    expect { delete_object }.to output("Deleted my-file.txt\n").to_stdout

    expect(@bucket.file "my-file.txt").to be nil
  end

  it "delete bucket" do
    # Google Cloud Storage bucket IDs are unique
    #
    # To prevent deleting the bucket that is used for testing,
    # this test simply verifies that the correct `#delete_bucket`
    # method is called by the sample
    expect(@bucket).to receive(:delete)

    expect { delete_bucket }.to output("Deleted bucket: #{@bucket.name}\n").
                                to_stdout
  end
end
