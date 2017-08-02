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

def list_bucket_contents project_id:, bucket_name:
  # [START list_bucket_contents]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Your Google Cloud Storage bucket name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id
  bucket  = storage.bucket bucket_name

  bucket.files.each do |file|
    puts file.name
  end
  # [END list_bucket_contents]
end

def list_bucket_contents_with_prefix project_id:, bucket_name:, prefix:
  # [START list_bucket_contents_with_prefix]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Your Google Cloud Storage bucket name"
  # prefix      = "Filter results to files whose names begin with this prefix"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id
  bucket  = storage.bucket bucket_name
  files   = bucket.files prefix: prefix

  files.each do |file|
    puts file.name
  end
  # [END list_bucket_contents_with_prefix]
end

def generate_encryption_key_base64
  # [START generate_encryption_key_base64]
  require "base64"
  require "openssl"

  encryption_key  = OpenSSL::Cipher.new("aes-256-cfb").encrypt.random_key
  encoded_enc_key = Base64.encode64 encryption_key

  puts "Sample encryption key: #{encoded_enc_key}"
  # [END generate_encryption_key_base64]
end

def upload_file project_id:, bucket_name:, local_file_path:,
                storage_file_path: nil
  # [START upload_file]
  # project_id        = "Your Google Cloud project ID"
  # bucket_name       = "Your Google Cloud Storage bucket name"
  # local_file_path   = "Path to local file to upload"
  # storage_file_path = "Path to store the file in Google Cloud Storage"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id
  bucket  = storage.bucket bucket_name

  file = bucket.create_file local_file_path, storage_file_path

  puts "Uploaded #{file.name}"
  # [END upload_file]
end

def upload_encrypted_file project_id:, bucket_name:, local_file_path:,
                          storage_file_path: nil, encryption_key:
  # [START upload_encrypted_file]
  # project_id        = "Your Google Cloud project ID"
  # bucket_name       = "Your Google Cloud Storage bucket name"
  # local_file_path   = "Path to local file to upload"
  # storage_file_path = "Path to store the file in Google Cloud Storage"
  # encryption_key    = "AES-256 encryption key"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id

  bucket = storage.bucket bucket_name

  file = bucket.create_file local_file_path, storage_file_path,
                            encryption_key: encryption_key

  puts "Uploaded #{file.name} with encryption key"
  # [END upload_encrypted_file]
end

def download_file project_id:, bucket_name:, file_name:, local_path:
  # [START download_file]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of file in Google Cloud Storage to download locally"
  # local_path  = "Path to local file to save"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  file.download local_path

  puts "Downloaded #{file.name}"
  # [END download_file]
end

def download_file_requester_pays project_id:, bucket_name:, file_name:, local_path:
  # [START download_file_requester_pays]
  # project_id  = "Your Google Cloud billable project ID"
  # bucket_name = "A Google Cloud Storage bucket name"
  # file_name   = "Name of file in Google Cloud Storage to download locally"
  # local_path  = "Path to local file to save"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id
  bucket  = storage.bucket bucket_name, skip_lookup: true, user_project: true
  file    = bucket.file file_name

  file.download local_path

  puts "Downloaded #{file.name} using billing project #{project_id}"
  # [END download_file_requester_pays]
end

def download_encrypted_file project_id:, bucket_name:, storage_file_path:,
                            local_file_path:, encryption_key:
  # [START download_encrypted_file]
  # project_id     = "Your Google Cloud project ID"
  # bucket_name    = "Your Google Cloud Storage bucket name"
  # file_name      = "Name of file in Google Cloud Storage to download locally"
  # local_path     = "Path to local file to save"
  # encryption_key = "AES-256 encryption key"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id

  bucket = storage.bucket bucket_name

  file = bucket.file storage_file_path, encryption_key: encryption_key
  file.download local_file_path, encryption_key: encryption_key

  puts "Downloaded encrypted #{file.name}"
  # [END download_encrypted_file]
end

def delete_file project_id:, bucket_name:, file_name:
  # [START delete_file]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of file in Google Cloud Storage to delete"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  file.delete

  puts "Deleted #{file.name}"
  # [END delete_file]
end

def list_file_details project_id:, bucket_name:, file_name:
  # [START list_file_details]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of file in Google Cloud Storage"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  puts "Name: #{file.name}"
  puts "Bucket: #{bucket.name}"
  puts "Storage class: #{bucket.storage_class}"
  puts "ID: #{file.id}"
  puts "Size: #{file.size} bytes"
  puts "Created: #{file.created_at}"
  puts "Updated: #{file.updated_at}"
  puts "Generation: #{file.generation}"
  puts "Metageneration: #{file.metageneration}"
  puts "Etag: #{file.etag}"
  puts "Owners: #{file.acl.owners.join ","}"
  puts "Crc32c: #{file.crc32c}"
  puts "md5_hash: #{file.md5}"
  puts "Cache-control: #{file.cache_control}"
  puts "Content-type: #{file.content_type}"
  puts "Content-disposition: #{file.content_disposition}"
  puts "Content-encoding: #{file.content_encoding}"
  puts "Content-language: #{file.content_language}"
  puts "Metadata:"
  file.metadata.each do |key, value|
    puts " - #{key} = #{value}"
  end
  # [END list_file_details]
end

def make_file_public project_id:, bucket_name:, file_name:
  # [START make_file_public]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of file in Google Cloud Storage to make public"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  file.acl.public!

  puts "#{file.name} is publicly accessible at #{file.public_url}"
  # [END make_file_public]
end

def rename_file project_id:, bucket_name:, file_name:, new_name:
  # [START rename_file]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of file in Google Cloud Storage to rename"
  # new_name    = "File will be renamed to this new name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  renamed_file = file.copy new_name

  file.delete

  puts "my-file.txt has been renamed to #{renamed_file.name}"
  # [END rename_file]
end

def copy_file project_id:, source_bucket_name:, source_file_name:,
                             dest_bucket_name:,   dest_file_name:
  # [START copy_file]
  # project_id         = "Your Google Cloud project ID"
  # source_bucket_name = "Source bucket to copy file from"
  # source_file_name   = "Source file name"
  # dest_bucket_name   = "Destination bucket to copy file to"
  # dest_file_name     = "Destination file name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id
  bucket  = storage.bucket source_bucket_name
  file    = bucket.file source_file_name

  destination_bucket = storage.bucket dest_bucket_name
  destination_file   = file.copy destination_bucket.name, file.name

  puts "#{file.name} in #{bucket.name} copied to " +
       "#{copied_file.name} in #{destination_bucket.name}"
  # [END copy_file]
end

def rotate_encryption_key project_id:, bucket_name:, file_name:,
                          current_encryption_key:, new_encryption_key:
  # [START rotate_encryption_key]
  # project_id             = "Your Google Cloud project ID"
  # bucket_name            = "Your Google Cloud Storage bucket name"
  # file_name              = "Name of a file in the Cloud Storage bucket"
  # current_encryption_key = "Encryption key currently being used"
  # new_encryption_key     = "New encryption key to use"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name, encryption_key: current_encryption_key

  file.rotate encryption_key:     current_encryption_key,
              new_encryption_key: new_encryption_key

  puts "The encryption key for #{file.name} in #{bucket.name} was rotated."
  # [END rotate_encryption_key]
end

def generate_signed_url project_id:, bucket_name:, file_name:
  # [START generate_signed_url]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of a file in the Cloud Storage bucket"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  url = file.signed_url

  puts "The signed url for #{file_name} is #{url}"
  # [END generate_signed_url]
end

def run_sample arguments
  command    = arguments.shift
  project_id = ENV["GOOGLE_CLOUD_PROJECT"]

  case command
  when "list"
    list_bucket_contents project_id:  project_id,
                         bucket_name: arguments.shift
  when "upload"
    upload_file project_id:      project_id,
                bucket_name:     arguments.shift,
                local_file_path: arguments.shift
  when "encrypted_upload"
    upload_encrypted_file project_id:      project_id,
                          bucket_name:     arguments.shift,
                          local_file_path: arguments.shift,
                          encryption_key:  Base64.decode64(arguments.shift)
  when "download"
    download_file project_id:  project_id,
                  bucket_name: arguments.shift,
                  file_name:   arguments.shift,
                  local_path:  arguments.shift
  when "encrypted_download"
    download_file project_id:    project_id,
                  bucket_name:   arguments.shift,
                  file_name:     arguments.shift,
                  local_path:    arguments.shift,
                  encrypted_key: Base64.decode64(arguments.shift)
  when "download_with_requester_pays"
    download_file_requester_pays project_id:  arguments.shift,
                                 bucket_name: arguments.shift,
                                 file_name:   arguments.shift,
                                 local_path:  arguments.shift
  when "rotate_encryption_key"
    rotate_encryption_key project_id:             project_id,
                          bucket_name:            arguments.shift,
                          file_name:              arguments.shift,
                          current_encryption_key: arguments.shift,
                          new_encryption_key:     arguments.shift
  when "generate_encryption_key"
    generate_encryption_key_base64
  when "delete"
    delete_file project_id:  project_id,
                bucket_name: arguments.shift,
                file_name:   arguments.shift
  when "metadata"
    list_file_details project_id:  project_id,
                      bucket_name: arguments.shift,
                      file_name:   arguments.shift
  when "make_public"
    make_file_public project_id:  project_id,
                     bucket_name: arguments.shift,
                     file_name:   arguments.shift
  when "rename"
    rename_file project_id:  project_id,
                bucket_name: arguments.shift,
                file_name:   arguments.shift,
                new_name:    arguments.shift
  when "copy"
    copy_file project_id:         project_id,
              source_bucket_name: arguments.shift,
              source_file_name:   arguments.shift,
              dest_bucket_name:   arguments.shift,
              dest_file_name:     arguments.shift
  when "generate_signed_url"
    generate_signed_url project_id:  project_id,
                        bucket_name: arguments.shift,
                        file_name:   arguments.shift
  else
    puts <<-usage
Usage: bundle exec ruby files.rb [command] [arguments]

Commands:
  list              <bucket>                                        List all files in the bucket
  upload            <bucket> <file>                                 Upload local file to a bucket
  encrypted_upload  <bucket> <file> <base64_encryption_key>         Upload local file as an encrypted file to a bucket
  download           <bucket> <file> <path>                         Download a file from a bucket
  encrypted_download <bucket> <file> <path> <base64_encryption_key> Download an encrypted file from a bucket
  download_with_requester_pays <project> <bucket> <file> <path>     Download a file from a requester pays enabled bucket
  rotate_encryption_key <bucket> <file> <base64_current_encryption_key> <base64_new_encryption_key> Update encryption key of an encrypted file.
  generate_encryption_key                                           Generate a sample encryption key
  delete       <bucket> <file>                                      Delete a file from a bucket
  metadata     <bucket> <file>                                      Display metadata for a file in a bucket
  make_public  <bucket> <file>                                      Make a file in a bucket public
  rename       <bucket> <file> <new>                                Rename a file in a bucket
  copy <srcBucket> <srcFile> <destBucket> <destFile>                Copy file to other bucket
  generate_signed_url <bucket> <file>                               Generate a signed url for a file

Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    usage
  end
end

if __FILE__ == $PROGRAM_NAME
  run_sample ARGV
end
