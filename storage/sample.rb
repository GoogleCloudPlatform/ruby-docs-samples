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

def create_bucket
  # [START create_bucket]
  require "gcloud"

  gcloud  = Gcloud.new "my-project-id"
  storage = gcloud.storage

  bucket = storage.create_bucket "my-bucket-name"

  puts "Created bucket: #{bucket.name}"
  # [END create_bucket]
end

def upload_object
  # [START upload_object]
  require "gcloud"

  gcloud  = Gcloud.new "my-project-id"
  storage = gcloud.storage
  bucket  = storage.bucket "my-bucket-name"

  file = bucket.create_file "/path/to/my-file.txt", "my-file.txt"

  puts "Uploaded #{file.name}"
  # [END upload_object]
end

def download_object
  # [START download_object]
  require "gcloud"

  gcloud  = Gcloud.new "my-project-id"
  storage = gcloud.storage
  bucket  = storage.bucket "my-bucket-name"
  file    = bucket.file "my-file.txt"

  file.download "/path/to/my-file.txt"

  puts "Downloaded #{file.name}"
  # [END download_object]
end

def make_object_public
  # [START make_object_public]
  require "gcloud"

  gcloud  = Gcloud.new "my-project-id"
  storage = gcloud.storage
  bucket  = storage.bucket "my-bucket-name"
  file    = bucket.file "my-file.txt"

  file.acl.public!

  puts "#{file.name} is publicly accessible at #{file.public_url}"
  # [END make_object_public]
end

def rename_object
  # [START rename_object]
  require "gcloud"

  gcloud  = Gcloud.new "my-project-id"
  storage = gcloud.storage
  bucket  = storage.bucket "my-bucket-name"
  file    = bucket.file "my-file.txt"

  renamed_file = file.copy "renamed-file.txt"

  file.delete

  puts "my-file.txt has been renamed to #{renamed_file.name}"
  # [END rename_object]
end

def copy_object_between_buckets
  # [START copy_object_between_buckets]
  require "gcloud"

  gcloud  = Gcloud.new "my-project-id"
  storage = gcloud.storage
  bucket  = storage.bucket "my-bucket-name"
  file    = bucket.file "my-file.txt"

  other_bucket = storage.bucket "other-bucket-name"
  copied_file  = file.copy other_bucket.name, file.name

  puts "#{file.name} in #{bucket.name} copied to " +
       "#{copied_file.name} in #{other_bucket.name}"
  # [END copy_object_between_buckets]
end

def list_bucket_contents
  # [START list_bucket_contents]
  require "gcloud"

  gcloud  = Gcloud.new "my-project-id"
  storage = gcloud.storage
  bucket  = storage.bucket "my-bucket-name"

  bucket.files.each do |file|
    puts file.name
  end
  # [END list_bucket_contents]
end

def list_object_details
  # [START list_object_details]
  require "gcloud"

  gcloud  = Gcloud.new "my-project-id"
  storage = gcloud.storage
  bucket  = storage.bucket "my-bucket-name"
  file    = bucket.file "my-file.txt"

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

def delete_bucket
  # [START delete_bucket]
  require "gcloud"

  gcloud  = Gcloud.new "my-project-id"
  storage = gcloud.storage
  # [END delete_bucket]
end
