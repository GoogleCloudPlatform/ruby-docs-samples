# Copyright 2016 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in write, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# TODO use consistent wording : "object" | "blob" | file"

def list_bucket_contents project_id:, bucket_name:
  # [START list_bucket_contents]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Your Google Cloud Storage bucket name"

  require "gcloud"

  gcloud  = Gcloud.new project_id
  storage = gcloud.storage
  bucket  = storage.bucket bucket_name

  bucket.files.each do |file|
    puts file.name
  end
  # [END list_bucket_contents]
end

# TODO
# def list_bucket_contents_with_prefix

def upload_object project_id:, bucket_name:, local_path:
  # [START upload_object]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Your Google Cloud Storage bucket name"
  # local_path  = "Path to local file to upload"

  require "gcloud"

  gcloud  = Gcloud.new project_id
  storage = gcloud.storage
  bucket  = storage.bucket bucket_name

  file = bucket.create_file local_path

  puts "Uploaded #{file.name}"
  # [END upload_object]
end

def download_object project_id:, bucket_name:, file_name:, local_path:
  # [START download_object]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of file in Google Cloud Storage to download locally"
  # local_path  = "Path to local file to save"

  require "gcloud"

  gcloud  = Gcloud.new project_id
  storage = gcloud.storage
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  file.download local_path

  puts "Downloaded #{file.name}"
  # [END download_object]
end

def delete_object project_id:, bucket_name:, file_name:
  # [START delete_object]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of file in Google Cloud Storage to delete"

  require "gcloud"

  gcloud  = Gcloud.new project_id
  storage = gcloud.storage
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  file.delete

  puts "Deleted #{file.name}"
  # [END delete_object]
end

def list_object_details project_id:, bucket_name:, file_name:
  # [START list_object_details]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of file in Google Cloud Storage"

  require "gcloud"

  gcloud  = Gcloud.new project_id
  storage = gcloud.storage
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
  # [END list_object_details]
end

def make_object_public project_id:, bucket_name:, file_name:
  # [START make_object_public]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of file in Google Cloud Storage to make public"

  require "gcloud"

  gcloud  = Gcloud.new project_id
  storage = gcloud.storage
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  file.acl.public!

  puts "#{file.name} is publicly accessible at #{file.public_url}"
  # [END make_object_public]
end

# TODO
# def generate_signed_url

def rename_object project_id:, bucket_name:, file_name:, new_name:
  # [START rename_object]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Your Google Cloud Storage bucket name"
  # file_name   = "Name of file in Google Cloud Storage to rename"
  # new_name    = "File will be renamed to this new name"

  require "gcloud"

  gcloud  = Gcloud.new project_id
  storage = gcloud.storage
  bucket  = storage.bucket bucket_name
  file    = bucket.file file_name

  renamed_file = file.copy new_name

  file.delete

  puts "my-file.txt has been renamed to #{renamed_file.name}"
  # [END rename_object]
end

def copy_object project_id:, source_bucket_name:, source_file_name:,
                             dest_bucket_name:,   dest_file_name:
  # [START copy_object]
  # project_id         = "Your Google Cloud project ID"
  # source_bucket_name = "Source bucket to copy file from"
  # source_file_name   = "Source file name"
  # dest_bucket_name   = "Destination bucket to copy file to"
  # dest_file_name     = "Destination file name"

  require "gcloud"

  gcloud  = Gcloud.new project_id
  storage = gcloud.storage
  bucket  = storage.bucket source_bucket_name
  file    = bucket.file source_file_name

  destination_bucket = storage.bucket dest_bucket_name
  destination_file   = file.copy destination_bucket.name, file.name

  puts "#{file.name} in #{bucket.name} copied to " +
       "#{copied_file.name} in #{destination_bucket.name}"
  # [END copy_object]
end

def run_sample arguments
  command = arguments.shift

  case command
  when "list"
    list_bucket_contents project_id:  ENV["GCLOUD_PROJECT"],
                         bucket_name: arguments.shift
  when "list_prefix"
    raise NotImplementedError, "list_prefix"
  when "upload"
    upload_object project_id:  ENV["GCLOUD_PROJECT"],
                  bucket_name: arguments.shift,
                  local_path:  arguments.shift
  when "download"
    download_object project_id:  ENV["GCLOUD_PROJECT"],
                    bucket_name: arguments.shift,
                    file_name:   arguments.shift,
                    local_path:  arguments.shift
  when "delete"
    delete_object project_id:  ENV["GCLOUD_PROJECT"],
                  bucket_name: arguments.shift,
                  file_name:   arguments.shift
  when "metadata"
    list_object_details project_id:  ENV["GCLOUD_PROJECT"],
                        bucket_name: arguments.shift,
                        file_name:   arguments.shift
  when "make_public"
    make_object_public project_id:  ENV["GCLOUD_PROJECT"],
                       bucket_name: arguments.shift,
                       file_name:   arguments.shift
  when "signed_url"
    raise NotImplementedError, "signed_url"
  when "rename"
    rename_object project_id:  ENV["GCLOUD_PROJECT"],
                  bucket_name: arguments.shift,
                  file_name:   arguments.shift,
                  new_name:    arguments.shift
  when "copy"
    copy_object project_id:         ENV["GCLOUD_PROJECT"],
                source_bucket_name: arguments.shift,
                source_file_name:   arguments.shift,
                dest_bucket_name:   arguments.shift,
                dest_file_name:     arguments.shift
  else
    puts <<-usage
Usage: bundle exec ruby files.rb [command] [arguments]

Commands:
  list        <bucket>                List all files in the bucket
  list_prefix <bucket> <prefix>       List all files with prefix in bucket
  upload      <bucket> <file>         Upload local file to a bucket
  download    <bucket> <file> <path>  Download a file from a bucket
  delete      <bucket> <file>         Delete a file from a bucket
  metadata    <bucket> <file>         Display metadata for a file in a bucket
  make_public <bucket> <file>         Make a file in a bucket public
  signed_url  <bucket> <file>         Generate a signed URL to access a file
  rename      <bucket> <file> <new>   Rename a file in a bucket
  copy <srcBucket> <srcFile> <destBucket> <destFile>  Copy file to other bucket

Environment variables:
  GCLOUD_PROJECT must be set to your Google Cloud project ID
    usage
  end
end

if __FILE__ == $0
  run_sample ARGV
end
