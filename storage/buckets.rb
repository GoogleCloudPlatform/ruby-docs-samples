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

def enable_default_kms_key project_id:, bucket_name:, default_kms_key:
  # [START storage_set_bucket_default_kms_key]
  # project_id      = "Your Google Cloud project ID"
  # bucket_name     = "Name of your Google Cloud Storage bucket"
  # default_kms_key = "KMS key resource id"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id
  bucket  = storage.bucket bucket_name

  bucket.default_kms_key = default_kms_key

  puts "Default KMS key for #{bucket.name} was set to #{bucket.default_kms_key}"
  # [END storage_set_bucket_default_kms_key]
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

def create_bucket_class_location project_id:, bucket_name:
  # [START create_bucket_class_location]
  # project_id    = "Your Google Cloud project ID"
  # bucket_name   = "Name of Google Cloud Storage bucket to create"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id
  bucket  = storage.create_bucket bucket_name,
                                  location:      "ASIA",
                                  storage_class: "COLDLINE"

  puts "Created bucket #{bucket.name}"
  # [END create_bucket_class_location]
end

def list_bucket_labels project_id:, bucket_name:
  # [START get_bucket_labels]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Name of your Google Cloud Storage bucket"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id
  bucket  = storage.bucket bucket_name

  puts "Labels for #{bucket_name}"
  bucket.labels.each do |key, value|
    puts "#{key} = #{value}"
  end
  # [END get_bucket_labels]
end

def add_bucket_label project_id:, bucket_name:, label_key:, label_value:
  # [START add_bucket_label]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Name of your Google Cloud Storage bucket"
  # label_key   = "Cloud Storage bucket Label Key"
  # label_value = "Cloud Storage bucket Label Value"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id
  bucket  = storage.bucket bucket_name

  bucket.update do |bucket|
    bucket.labels[label_key] = label_value
  end

  puts "Added label #{label_key} with value #{label_value} to #{bucket_name}"
  # [END add_bucket_label]
end

def delete_bucket_label project_id:, bucket_name:, label_key:
  # [START remove_bucket_label]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Name of your Google Cloud Storage bucket"
  # label_key   = "Cloud Storage bucket Label Key"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id
  bucket  = storage.bucket bucket_name

  bucket.update do |bucket|
    bucket.labels[label_key] = nil
  end

  puts "Deleted label #{label_key} from #{bucket_name}"
  # [END remove_bucket_label]
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
  when "enable_requester_pays"
    enable_requester_pays project_id:  ENV["GOOGLE_CLOUD_PROJECT"],
                          bucket_name: ARGV.shift
  when "disable_requester_pays"
    disable_requester_pays project_id:  ENV["GOOGLE_CLOUD_PROJECT"],
                           bucket_name: ARGV.shift
  when "enable_default_kms_key"
    enable_default_kms_key project_id:      ENV["GOOGLE_CLOUD_PROJECT"],
                           bucket_name:     ARGV.shift,
                           default_kms_key: ARGV.shift
  when "check_requester_pays"
    check_requester_pays project_id:  ENV["GOOGLE_CLOUD_PROJECT"],
                         bucket_name: ARGV.shift
  when "list_bucket_labels"
    list_bucket_labels project_id: ENV["GOOGLE_CLOUD_PROJECT"]
  when "add_bucket_label"
    add_bucket_label project_id:  ENV["GOOGLE_CLOUD_PROJECT"],
                     label_key:   ARGV.shift,
                     label_value: ARGV.shift
  when "delete_bucket_label"
    delete_bucket_label project_id: ENV["GOOGLE_CLOUD_PROJECT"],
                        label_key:  ARGV.shift
  when "create_with"
    create_bucket_class_location project_id:    ENV["GOOGLE_CLOUD_PROJECT"],
                                 bucket_name:   ARGV.shift
  else
    puts <<-usage
Usage: bundle exec ruby buckets.rb [command] [arguments]

Commands:
  list                                                       List all buckets in the authenticated project
  enable_requester_pays  <bucket>                            Enable requester pays for a bucket
  disable_requester_pays <bucket>                            Disable requester pays for a bucket
  check_requester_pays   <bucket>                            Check status of requester pays for a bucket
  enable_default_kms_key <bucket> <kms_key>                  Enable default KMS encryption for bucket
  create                 <bucket>                            Create a new bucket with the provided name
  create_with            <bucket>                            Create a new bucket with specific storage class and location
  list_bucket_labels     <bucket>                            List bucket labels
  add_bucket_label       <bucket> <label_key> <label_value>  Add bucket label
  delete_bucket_label    <bucket> <label_key>                Delete bucket label
  delete                 <bucket>                            Delete bucket with the provided name

Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    usage
  end
end
