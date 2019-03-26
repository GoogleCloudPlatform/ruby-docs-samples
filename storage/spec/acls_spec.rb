# Copyright 2017 Google, Inc
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

require_relative "../acls"
require "rspec"
require "rspec/retry"
require "google/cloud/storage"
require "tempfile"

RSpec.configure do |config|
  # show retry status in spec process
  config.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  config.display_try_failure_messages = true

  # set retry count and retry sleep interval to 10 seconds
  config.default_retry_count = 5
  config.default_sleep_interval = 10
end

describe "Google Cloud Storage ACL sample" do
  before do
    @bucket_name     = ENV["GOOGLE_CLOUD_STORAGE_BUCKET"]
    @storage         = Google::Cloud::Storage.new
    @project_id      = @storage.project
    @bucket          = @storage.bucket @bucket_name
    @local_file_path = File.expand_path "resources/file.txt", __dir__
    @test_email      = "user-test@test.com"

    @storage.create_bucket @bucket_name if @bucket.nil?
  end

  # Delete given file in Cloud Storage test bucket if it exists
  def delete_file storage_file_path
    @bucket.file(storage_file_path)&.delete
  end

  def upload local_file_path, storage_file_path
    @bucket.create_file local_file_path, storage_file_path unless @bucket.file storage_file_path
  end

  # Capture and return STDOUT output by block
  def capture
    real_stdout = $stdout
    $stdout = StringIO.new
    yield
    @captured_output = $stdout.string
  ensure
    $stdout = real_stdout
  end
  attr_reader :captured_output

  it "can print bucket acl" do
    @bucket.acl.add_owner @test_email
    @bucket.reload!

    expect(@bucket.acl.owners).to include @test_email

    capture do
      print_bucket_acl project_id: @project_id, bucket_name: @bucket_name
    end

    expect(captured_output).to include "OWNER #{@test_email}"
  end

  it "can print bucket acl for user" do
    @bucket.acl.add_owner @test_email
    @bucket.acl.reload!

    expect(@bucket.acl.owners).to include @test_email

    capture do
      print_bucket_acl_for_user project_id:  @project_id,
                                bucket_name: @bucket_name,
                                email:       @test_email
    end

    expect(captured_output).to include "Permissions for #{@test_email}"
    expect(captured_output).to include "OWNER"
  end

  it "can add bucket owner" do
    @bucket.acl.delete @test_email if @bucket.acl.owners.include? @test_email
    @bucket.acl.reload!

    expect(@bucket.acl.owners).not_to include @test_email

    expect {
      add_bucket_owner project_id:  @project_id,
                       bucket_name: @bucket_name,
                       email:       @test_email
    }.to output(
      /Added OWNER permission for #{@test_email} to #{@bucket_name}/
    ).to_stdout

    @bucket.acl.reload!
    expect(@bucket.acl.owners).to include @test_email
  end

  it "can remove bucket acl" do
    @bucket.acl.add_owner @test_email
    @bucket.acl.reload!

    expect(@bucket.acl.owners).to include @test_email

    expect {
      remove_bucket_acl project_id:  @project_id,
                        bucket_name: @bucket_name,
                        email:       @test_email
    }.to output(
      /Removed ACL permissions for #{@test_email} from #{@bucket_name}/
    ).to_stdout

    @bucket.acl.reload!
    expect(@bucket.acl.owners).not_to include @test_email
  end

  it "can add bucket default owner" do
    @bucket.default_acl.delete @test_email if @bucket.default_acl.owners.include? @test_email

    expect(@bucket.default_acl.owners).not_to include @test_email

    expect {
      add_bucket_default_owner project_id:  @project_id,
                               bucket_name: @bucket_name,
                               email:       @test_email
    }.to output(
      /Added default OWNER permission for #{@test_email} to #{@bucket_name}/
    ).to_stdout

    @bucket.default_acl.reload!
    expect(@bucket.default_acl.owners).to include @test_email
  end

  it "can remove bucket default acl" do
    @bucket.default_acl.delete @test_email if @bucket.default_acl.owners.include? @test_email

    expect(@bucket.default_acl.owners).not_to include @test_email

    @bucket.default_acl.add_owner @test_email
    @bucket.default_acl.reload!

    expect(@bucket.default_acl.owners).to include @test_email

    expect {
      remove_bucket_default_acl project_id:  @project_id,
                                bucket_name: @bucket_name,
                                email:       @test_email
    }.to output(
      /Removed default ACL permissions for #{@test_email} from #{@bucket_name}/
    ).to_stdout

    @bucket.default_acl.reload!
    expect(@bucket.default_acl.owners).not_to include @test_email
  end

  it "can print file acl" do
    file_name = "acl_file.txt"

    upload @local_file_path, file_name

    file = @bucket.file file_name

    file.acl.add_owner @test_email
    file.acl.reload!

    expect(file.acl.owners).to include @test_email

    capture do
      print_file_acl project_id:  @project_id,
                     bucket_name: @bucket_name,
                     file_name:   file_name
    end

    expect(captured_output).to include "OWNER #{@test_email}"
  end

  it "can print file acl for user" do
    file_name = "acl_file.txt"

    upload @local_file_path, file_name

    file = @bucket.file file_name

    file.acl.add_owner @test_email
    file.acl.reload!

    expect(file.acl.owners).to include @test_email

    capture do
      print_file_acl_for_user project_id:  @project_id,
                              bucket_name: @bucket_name,
                              file_name:   file_name,
                              email:       @test_email
    end

    expect(captured_output).to include "Permissions for #{@test_email}"
    expect(captured_output).to include "OWNER"
  end

  it "can add file owner" do
    file_name = "acl_file.txt"

    upload @local_file_path, file_name

    file = @bucket.file file_name

    file.acl.delete @test_email if file.acl.owners.include? @test_email
    file.acl.reload!

    expect(file.acl.owners).not_to include @test_email

    expect {
      add_file_owner project_id:  @project_id,
                     bucket_name: @bucket_name,
                     file_name:   file_name,
                     email:       @test_email
    }.to output(
      /Added OWNER permission for #{@test_email} to #{file_name}/
    ).to_stdout

    file.acl.reload!
    expect(file.acl.owners).to include @test_email
  end

  it "can remove file acl" do
    file_name = "acl_file.txt"

    upload @local_file_path, file_name

    file = @bucket.file file_name

    file.acl.add_owner @test_email
    file.acl.reload!

    expect(file.acl.owners).to include @test_email

    expect {
      remove_file_acl project_id:  @project_id,
                      bucket_name: @bucket_name,
                      file_name:   file_name,
                      email:       @test_email
    }.to output(
      /Removed ACL permissions for #{@test_email} from #{file_name}/
    ).to_stdout

    file.acl.reload!
    expect(file.acl.owners).not_to include @test_email
  end
end
