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

require_relative "../files"
require "rspec"
require "google/cloud/storage"
require "tempfile"
require "net/http"
require "uri"

describe "Google Cloud Storage files sample" do

  before do
    @bucket_name          = ENV["GOOGLE_CLOUD_STORAGE_BUCKET"]
    @storage              = Google::Cloud::Storage.new
    @project_id           = @storage.project
    @bucket               = @storage.bucket @bucket_name
    @storage_secondary    = Google::Cloud::Storage.new project: ENV["GOOGLE_CLOUD_PROJECT_SECONDARY"],
                                                       keyfile: ENV["GOOGLE_APPLICATION_CREDENTIALS_SECONDARY"]
    @project_id_secondary = @storage_secondary.project
    @local_file_path      = File.expand_path "resources/file.txt", __dir__
    @encryption_key       = generate_encryption_key

    @bucket.policy do |policy|
      policy.add "roles/storage.objectViewer", "allUsers"
    end
  end

  after do
    @bucket.policy do |policy|
      policy.remove "roles/storage.objectViewer", "allUsers"
    end

    @bucket.requester_pays = false
  end

  def generate_encryption_key
    OpenSSL::Cipher.new("aes-256-cfb").encrypt.random_key
  end

  # Delete given file in Cloud Storage test bucket if it exists
  def delete_file storage_file_path
    @bucket.file(storage_file_path).delete if @bucket.file storage_file_path
  end

  # Upload a local file to the Cloud Storage test bucket
  def upload local_file_path, storage_file_path, encryption_key: nil
    unless @bucket.file storage_file_path
      @bucket.create_file local_file_path, storage_file_path,
                          encryption_key: encryption_key
    end
  end

  # Returns the content of an uploaded file in Cloud Storage test bucket
  def storage_file_content storage_file_path, encryption_key: nil
    local_tempfile = Tempfile.new "cloud-storage-tests"
    storage_file   = @bucket.file storage_file_path,
                                  encryption_key: encryption_key
    storage_file.download local_tempfile.path, encryption_key: encryption_key
    File.read local_tempfile.path
  ensure
    local_tempfile.close
    local_tempfile.unlink
  end

  # Capture and return STDOUT output by block
  def capture &block
    real_stdout = $stdout
    $stdout = StringIO.new
    block.call
    @captured_output = $stdout.string
  ensure
    $stdout = real_stdout
  end
  attr_reader :captured_output

  it "can generate a base64 encoded encryption key" do
    mock_cipher = double
    mock_encrypt = double
    encryption_key_base64 = Base64.encode64 @encryption_key

    # Mock OpenSSL::Cipher
    expect(OpenSSL::Cipher).to receive(:new).with("aes-256-cfb").and_return mock_cipher
    expect(mock_cipher).to     receive(:encrypt).and_return mock_encrypt
    expect(mock_encrypt).to    receive(:random_key).and_return @encryption_key

    expect {
      generate_encryption_key_base64
    }.to output{
      /Sample encryption key: #{encryption_key_base64}/
    }.to_stdout
  end

  it "can list files in a bucket" do
    upload @local_file_path, "file.txt"
    expect(@bucket.file "file.txt").not_to be nil

    expect {
      list_bucket_contents project_id:  @project_id,
                           bucket_name: @bucket_name
    }.to output(
      /file\.txt/
    ).to_stdout
  end

  it "can list files with a prefix in a bucket" do
    upload @local_file_path, "foo/hello"
    upload @local_file_path, "foo/hi/there"
    upload @local_file_path, "bar/hello"
    upload @local_file_path, "bar/hi/there"

    capture do
      list_bucket_contents_with_prefix project_id:  @project_id,
                                       bucket_name: @bucket_name,
                                       prefix:      "foo/"
    end

    expect(captured_output).to     include "foo/hello"
    expect(captured_output).to     include "foo/hi/there"
    expect(captured_output).not_to include "bar/hello"
    expect(captured_output).not_to include "bar/hi/there"
  end

  it "can upload a local file to a bucket" do
    delete_file "file.txt"
    expect(@bucket.file "file.txt").to be nil

    expect {
      upload_file project_id:        @project_id,
                  bucket_name:       @bucket_name,
                  local_file_path:   @local_file_path,
                  storage_file_path: "file.txt"
    }.to output(
      /Uploaded .*file.txt/
    ).to_stdout

    expect(@bucket.file "file.txt").not_to be nil
    expect(storage_file_content "file.txt").to eq "Content of test file.txt\n"
  end

  it "can upload a local file to a bucket with encryption key" do
    delete_file "file.txt"
    expect(@bucket.file "file.txt").to be nil

    expect {
      upload_encrypted_file project_id:        @project_id,
                            bucket_name:       @bucket_name,
                            local_file_path:   @local_file_path,
                            storage_file_path: "file.txt",
                            encryption_key:    @encryption_key
    }.to output(
      "Uploaded file.txt with encryption key\n"
    ).to_stdout

    expect(@bucket.file "file.txt").not_to be nil
    expect(storage_file_content "file.txt", encryption_key: @encryption_key).
        to eq "Content of test file.txt\n"
  end

  it "can download a file from a bucket" do
    begin
      delete_file "file.txt"
      expect(@bucket.file "file.txt").to be nil

      upload @local_file_path, "file.txt"

      local_file = Tempfile.new "cloud-storage-tests"
      expect(File.size local_file.path).to eq 0

      expect {
        download_file project_id:  @project_id,
                      bucket_name: @bucket_name,
                      local_path:  local_file.path,
                      file_name:   "file.txt"
      }.to output(
        "Downloaded file.txt\n"
      ).to_stdout

      expect(File.size local_file.path).to be > 0
      expect(File.read local_file.path).to eq(
        "Content of test file.txt\n"
      )
    ensure
      local_file.close
      local_file.unlink
    end
  end

  it "can download a file from a bucket using requester pays" do
    begin
      @bucket.requester_pays = true
      expect(@storage.bucket(@bucket_name).requester_pays).to be true

      delete_file "file.txt"
      expect(@bucket.file "file.txt").to be nil

      upload @local_file_path, "file.txt"

      local_file = Tempfile.new "cloud-storage-tests"
      expect(File.size local_file.path).to eq 0

      expect(Google::Cloud::Storage).to receive(:new).
                                        with(project: @project_id_secondary).
                                        and_return @storage_secondary

      expect {
        download_file_requester_pays project_id:  @project_id_secondary,
                                     bucket_name: @bucket_name,
                                     local_path:  local_file.path,
                                     file_name:   "file.txt"
      }.to output(
        "Downloaded file.txt using billing project #{@project_id_secondary}\n"
      ).to_stdout

      expect(File.size local_file.path).to be > 0
      expect(File.read local_file.path).to eq(
        "Content of test file.txt\n"
      )
    ensure
      local_file.close
      local_file.unlink
    end
  end

  it "can't download a file from a bucket using requester pays without flag" do
    begin
      @bucket.requester_pays = true
      expect(@storage.bucket(@bucket_name).requester_pays).to be true

      delete_file "file.txt"
      expect(@bucket.file "file.txt").to be nil

      upload @local_file_path, "file.txt"

      local_file = Tempfile.new "cloud-storage-tests"
      expect(File.size local_file.path).to eq 0

      expect(Google::Cloud::Storage).to receive(:new).
                                        with(project: @project_id_secondary).
                                        and_return @storage_secondary

      expect {
        download_file project_id:  @project_id_secondary,
                      bucket_name: @bucket_name,
                      local_path:  local_file.path,
                      file_name:   "file.txt"
      }.to raise_error Google::Cloud::InvalidArgumentError

      expect(File.size local_file.path).to be 0
    ensure
      local_file.close
      local_file.unlink
    end
  end

  it "can download an encrypted file from a bucket" do
    begin
      delete_file "file.txt"
      expect(@bucket.file "file.txt").to be nil

      upload @local_file_path, "file.txt", encryption_key: @encryption_key

      local_file = Tempfile.new "cloud-storage-encryption-tests"
      expect(File.size local_file.path).to eq 0

      expect {
        download_encrypted_file project_id:        @project_id,
                                bucket_name:       @bucket_name,
                                storage_file_path: "file.txt",
                                local_file_path:   local_file.path,
                                encryption_key:    @encryption_key
      }.to output(
        "Downloaded encrypted file.txt\n"
      ).to_stdout

      expect(File.size local_file.path).to be > 0
      expect(File.read local_file.path).to eq "Content of test file.txt\n"
    ensure
      local_file.close
      local_file.unlink
    end
  end

  it "can't download an encrypted file from a bucket with wrong key" do
    begin
      delete_file "file.txt"
      expect(@bucket.file "file.txt").to be nil

      upload @local_file_path, "file.txt", encryption_key: @encryption_key

      local_file = Tempfile.new "cloud-storage-encryption-tests"
      expect(File.size local_file.path).to eq 0

      expect {
        download_encrypted_file project_id:        @project_id,
                                bucket_name:       @bucket_name,
                                storage_file_path: "file.txt",
                                local_file_path:   local_file.path,
                                encryption_key:    generate_encryption_key
      }.to raise_error Google::Cloud::InvalidArgumentError

      expect(File.size local_file.path).to eq 0
    ensure
      local_file.close
      local_file.unlink
    end
  end

  it "rotate encryption key for an encrypted file" do
    delete_file "file.txt"
    expect(@bucket.file "file.txt").to be nil

    upload @local_file_path, "file.txt", encryption_key: @encryption_key

    new_encryption_key = generate_encryption_key

    expect {
      rotate_encryption_key project_id:             @project_id,
                            bucket_name:            @bucket_name,
                            file_name:              "file.txt",
                            current_encryption_key: @encryption_key,
                            new_encryption_key:     new_encryption_key
    }.to output(
      "The encryption key for file.txt in #{@bucket_name} was rotated.\n"
    ).to_stdout

    expect(storage_file_content "file.txt", encryption_key: new_encryption_key).
        to eq "Content of test file.txt\n"
  end

  it "can generate a signed url for a file" do
    delete_file "file.txt"
    expect(@bucket.file "file.txt").to be nil

    upload @local_file_path, "file.txt"

    capture do
      generate_signed_url project_id:  @project_id,
                          bucket_name: @bucket_name,
                          file_name:   "file.txt"
    end

    expect(@captured_output).to include "The signed url for file.txt"

    signed_url_from_output = @captured_output.scan(/http.*$/).first

    file_contents = Net::HTTP.get URI(signed_url_from_output)

    expect(file_contents).to include "Content of test file.txt"
  end
end
