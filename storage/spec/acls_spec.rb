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
require "google/cloud/storage"
require "tempfile"

describe "Google Cloud Storage ACL sample" do

  before do
    @bucket_name     = ENV["GOOGLE_CLOUD_STORAGE_BUCKET"]
    @storage         = Google::Cloud::Storage.new
    @project_id      = @storage.project
    @bucket          = @storage.bucket @bucket_name
    @local_file_path = File.expand_path "resources/file.txt", __dir__
    @test_email      = "user-test@test.com"
  end

  # Delete given file in Cloud Storage test bucket if it exists
  def delete_file storage_file_path
    @bucket.file(storage_file_path).delete if @bucket.file storage_file_path
  end

  def upload local_file_path, storage_file_path
    unless @bucket.file storage_file_path
      @bucket.create_file local_file_path, storage_file_path
    end
  end

  def email_in_bucket_acl? email
    @bucket.acl.owners.include?(email)    ||
      @bucket.acl.writers.include?(email) ||
      @bucket.acl.readers.include?(email)
  end

  def email_in_default_bucket_acl? email
    @bucket.default_acl.owners.include?(email)    ||
      @bucket.default_acl.readers.include?(email)
  end

  def email_in_file_acl? file_path, email
    file = @bucket.file file_path

    file.acl.owners.include?(email)    ||
      file.acl.readers.include?(email)
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

  it "can print owner bucket acl" do
    @bucket.acl.delete(@test_email) if email_in_bucket_acl?(@test_email)
    @bucket.acl.reload!

    expect(@bucket.acl.owners).not_to include(@test_email)

    @bucket.acl.add_owner @test_email
    @bucket.reload!

    expect(@bucket.acl.owners).to include(@test_email)

    capture do
      print_bucket_acl project_id: @project_id, bucket_name: @bucket_name
    end

    expect(captured_output).to include "OWNER #{@test_email}"
  end

  it "can print writer bucket acl" do
    @bucket.acl.delete(@test_email) if email_in_bucket_acl?(@test_email)
    @bucket.acl.reload!

    expect(@bucket.acl.writers).not_to include(@test_email)

    @bucket.acl.add_writer @test_email
    @bucket.acl.reload!

    expect(@bucket.acl.writers).to include(@test_email)

    capture do
      print_bucket_acl project_id: @project_id, bucket_name: @bucket_name
    end

    expect(captured_output).to include "WRITER #{@test_email}"
  end

  it "can print reader bucket acl" do
    @bucket.acl.delete(@test_email) if email_in_bucket_acl?(@test_email)
    @bucket.acl.reload!

    expect(@bucket.acl.readers).not_to include(@test_email)

    @bucket.acl.add_reader @test_email
    @bucket.acl.reload!

    expect(@bucket.acl.readers).to include(@test_email)

    capture do
      print_bucket_acl project_id: @project_id, bucket_name: @bucket_name
    end

    expect(captured_output).to include "READER #{@test_email}"
  end

  it "can print bucket OWNER acl for user" do
    @bucket.acl.delete(@test_email) if email_in_bucket_acl?(@test_email)
    @bucket.acl.reload!

    expect(@bucket.acl.owners).not_to include(@test_email)

    @bucket.acl.add_owner @test_email
    @bucket.acl.reload!

    expect(@bucket.acl.owners).to include(@test_email)

    capture do
      print_bucket_acl_for_user(project_id:  @project_id,
                                bucket_name: @bucket_name,
                                email:       @test_email)
    end

    expect(captured_output).to include "Permissions for #{@test_email}"
    expect(captured_output).to include "OWNER"
  end

  it "can print bucket WRITER acl for user" do
    @bucket.acl.delete(@test_email) if email_in_bucket_acl?(@test_email)
    @bucket.acl.reload!

    expect(@bucket.acl.writers).not_to include(@test_email)

    @bucket.acl.add_writer @test_email
    @bucket.acl.reload!

    expect(@bucket.acl.writers).to include(@test_email)

    capture do
      print_bucket_acl_for_user(project_id:  @project_id,
                                bucket_name: @bucket_name,
                                email:       @test_email)
    end

    expect(captured_output).to include "Permissions for #{@test_email}"
    expect(captured_output).to include "WRITER"
  end

  it "can print bucket READER acl for user" do
    @bucket.acl.delete(@test_email) if email_in_bucket_acl?(@test_email)
    @bucket.acl.reload!

    expect(@bucket.acl.readers).not_to include(@test_email)

    @bucket.acl.add_reader @test_email
    @bucket.acl.reload!

    expect(@bucket.acl.readers).to include(@test_email)

    capture do
      print_bucket_acl_for_user(project_id:  @project_id,
                                bucket_name: @bucket_name,
                                email:       @test_email)
    end

    expect(captured_output).to include "Permissions for #{@test_email}"
    expect(captured_output).to include "READER"
  end


  it "can add bucket owner" do
    @bucket.acl.delete(@test_email) if email_in_bucket_acl?(@test_email)
    @bucket.acl.reload!

    expect(@bucket.acl.owners).not_to include(@test_email)

    expect {
      add_bucket_owner(project_id:  @project_id,
                       bucket_name: @bucket_name,
                       email:       @test_email)
    }.to output(
      /Added OWNER permission for #{@test_email} to #{@bucket_name}/
    ).to_stdout

    @bucket.acl.reload!
    expect(@bucket.acl.owners).to include(@test_email)
  end

  it "can remove bucket owner" do
    @bucket.acl.delete @test_email if email_in_bucket_acl?(@test_email)
    @bucket.acl.reload!

    expect(@bucket.acl.owners).not_to include(@test_email)

    @bucket.acl.add_owner @test_email
    @bucket.acl.reload!

    expect(@bucket.acl.owners).to include(@test_email)

    expect {
      remove_bucket_owner(project_id:  @project_id,
                          bucket_name: @bucket_name,
                          email:       @test_email)
    }.to output(
      /Removed OWNER permission for #{@test_email} from #{@bucket_name}/
    ).to_stdout

    @bucket.acl.reload!
    expect(@bucket.acl.owners).not_to include(@test_email)
  end

  it "can add bucket default owner" do
    if email_in_default_bucket_acl?(@test_email)
      @bucket.default_acl.delete @test_email
    end

    expect(@bucket.default_acl.owners).not_to include(@test_email)

    expect {
      add_bucket_default_owner(project_id:  @project_id,
                               bucket_name: @bucket_name,
                               email:       @test_email)
    }.to output(
      /Added default OWNER permission for #{@test_email} to #{@bucket_name}/
    ).to_stdout

    @bucket.default_acl.reload!
    expect(@bucket.default_acl.owners).to include(@test_email)
  end

  it "can remove bucket default owner" do
    if email_in_default_bucket_acl?(@test_email)
      @bucket.default_acl.delete @test_email
    end

    expect(@bucket.default_acl.owners).not_to include(@test_email)

    @bucket.default_acl.add_owner @test_email
    @bucket.default_acl.reload!

    expect(@bucket.default_acl.owners).to include(@test_email)

    expect {
      remove_bucket_default_owner(project_id:  @project_id,
                                  bucket_name: @bucket_name,
                                  email:       @test_email)
    }.to output(
      /Removed default OWNER permission for #{@test_email} from #{@bucket_name}/
    ).to_stdout

    @bucket.default_acl.reload!
    expect(@bucket.default_acl.owners).not_to include(@test_email)
  end

  it "can print file OWNER acl" do
    file_name = "acl_file.txt"

    upload @local_file_path, file_name

    file = @bucket.file file_name

    file.acl.delete @test_email if email_in_file_acl? file_name, @test_email
    file.acl.reload!

    expect(file.acl.owners).not_to include(@test_email)

    file.acl.add_owner @test_email
    file.acl.reload!

    expect(file.acl.owners).to include(@test_email)

    capture do
      print_file_acl(project_id: @project_id, bucket_name: @bucket_name,
                     file_name:  file_name)
    end

    expect(captured_output).to include "OWNER #{@test_email}"
  end

  it "can print file READER acl" do
    file_name = "acl_file.txt"

    upload @local_file_path, file_name

    file = @bucket.file file_name

    file.acl.delete @test_email if email_in_file_acl? file_name, @test_email
    file.acl.reload!

    expect(file.acl.readers).not_to include(@test_email)

    file.acl.add_reader @test_email
    file.acl.reload!

    expect(file.acl.readers).to include(@test_email)

    capture do
      print_file_acl(project_id: @project_id, bucket_name: @bucket_name,
                     file_name:  file_name)
    end

    expect(captured_output).to include "READER #{@test_email}"
  end


  it "can print file OWNER acl for user" do
    file_name = "acl_file.txt"

    upload @local_file_path, file_name

    file = @bucket.file file_name

    file.acl.delete @test_email if email_in_file_acl? file_name, @test_email
    file.acl.reload!

    expect(file.acl.owners).not_to include(@test_email)

    file.acl.add_owner @test_email
    file.acl.reload!

    expect(file.acl.owners).to include(@test_email)

    capture do
      print_file_acl_for_user(project_id:  @project_id,
                              bucket_name: @bucket_name,
                              file_name:   file_name,
                              email:       @test_email)
    end

    expect(captured_output).to include "Permissions for #{@test_email}"
    expect(captured_output).to include "OWNER"
  end

  it "can print file READER acl for user" do
    file_name = "acl_file.txt"

    upload @local_file_path, file_name

    file = @bucket.file file_name

    file.acl.delete @test_email if email_in_file_acl? file_name, @test_email
    file.acl.reload!

    expect(file.acl.readers).not_to include(@test_email)

    file.acl.add_reader @test_email
    file.acl.reload!

    expect(file.acl.readers).to include(@test_email)

    capture do
      print_file_acl_for_user(project_id:  @project_id,
                              bucket_name: @bucket_name,
                              file_name:   file_name,
                              email:       @test_email)
    end

    expect(captured_output).to include "Permissions for #{@test_email}"
    expect(captured_output).to include "READER"
  end


  it "can add file owner" do
    file_name = "acl_file.txt"

    upload @local_file_path, file_name

    file = @bucket.file file_name

    file.acl.delete @test_email if email_in_file_acl? file_name, @test_email
    file.acl.reload!

    expect(file.acl.owners).not_to include(@test_email)

    expect {
      add_file_owner(project_id:  @project_id,
                     bucket_name: @bucket_name,
                     file_name:   file_name,
                     email:       @test_email)
    }.to output(
      /Added OWNER permission for #{@test_email} to #{file_name}/
    ).to_stdout

    file.acl.reload!
    expect(file.acl.owners).to include(@test_email)
  end

  it "can remove file owner" do
    file_name = "acl_file.txt"

    upload @local_file_path, file_name

    file = @bucket.file file_name

    file.acl.delete @test_email if email_in_file_acl? file_name, @test_email
    file.acl.reload!

    expect(file.acl.owners).not_to include(@test_email)

    file.acl.add_owner @test_email
    file.acl.reload!

    expect(file.acl.owners).to include(@test_email)

    expect {
      remove_file_owner(project_id:  @project_id,
                        bucket_name: @bucket_name,
                        file_name:   file_name,
                        email:       @test_email)
    }.to output(
      /Removed OWNER permission for #{@test_email} from #{file_name}/
    ).to_stdout

    file.acl.reload!
    expect(file.acl.owners).not_to include(@test_email)
  end
end
