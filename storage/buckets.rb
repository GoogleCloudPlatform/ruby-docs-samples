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

def list_buckets project_id:
  # [START list_buckets]
  # project_id = "Your Google Cloud project ID"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id

  storage.buckets.each do |bucket|
    puts bucket.name
  end
  # [END list_buckets]
end

def disable_requester_pays project_id:, bucket_name:
  # [START disable_requester_pays]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Name of your Google Cloud Storage bucket"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id
  bucket  = storage.bucket bucket_name

  bucket.requester_pays = false

  puts "Requester pays has been disabled for #{bucket_name}"
  # [END disable_requester_pays]
end

def enable_requester_pays project_id:, bucket_name:
  # [START enable_requester_pays]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Name of your Google Cloud Storage bucket"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id
  bucket  = storage.bucket bucket_name

  bucket.requester_pays = true

  puts "Requester pays has been enabled for #{bucket_name}"
  # [END enable_requester_pays]
end

def get_requester_pays_status project_id:, bucket_name:
  # [START get_requester_pays_status]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Name of your Google Cloud Storage bucket"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id
  bucket  = storage.bucket bucket_name

  if bucket.requester_pays
    puts "Requester Pays is enabled for #{bucket_name}"
  else
    puts "Requester Pays is disabled for #{bucket_name}"
  end
  # [END get_requester_pays_status]
end

def create_bucket project_id:, bucket_name:
  # [START create_bucket]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Name of Google Cloud Storage bucket to create"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id
  bucket  = storage.create_bucket bucket_name

  puts "Created bucket: #{bucket.name}"
  # [END create_bucket]
end

def delete_bucket project_id:, bucket_name:
  # [START delete_bucket]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Name of your Google Cloud Storage bucket to delete"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id
  bucket  = storage.bucket bucket_name

  bucket.delete

  puts "Deleted bucket: #{bucket.name}"
  # [END delete_bucket]
end

if __FILE__ == $0
  case ARGV.shift
  when "list"
    list_buckets project_id: ENV["GOOGLE_CLOUD_PROJECT"]
  when "create"
    create_bucket project_id:  ENV["GOOGLE_CLOUD_PROJECT"],
                  bucket_name: ARGV.shift
  when "delete"
    delete_bucket project_id:  ENV["GOOGLE_CLOUD_PROJECT"],
                  bucket_name: ARGV.shift
  else
    puts <<-usage
Usage: bundle exec ruby buckets.rb [command] [arguments]

Commands:
  list                            List all buckets in the authenticated project
  enable_requester_pays  <bucket> Enable requester pays for a bucket
  disable_requester_pays <bucket> Disable requester pays for a bucket
  check_requester_pays   <bucket> Check status of requester pays for a bucket
  create                 <bucket> Create a new bucket with the provided name
  delete                 <bucket> Delete bucket with the provided name

Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    usage
  end
end
