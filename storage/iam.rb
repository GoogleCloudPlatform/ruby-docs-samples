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

def view_bucket_iam_members project_id:, bucket_name:
  # [START view_bucket_iam_members]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Your Google Cloud Storage bucket name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project_id: project_id
  bucket = storage.bucket bucket_name

  policy = bucket.policy

  policy.roles.each do |role, members|
    puts "Role: #{role} Members: #{members}"
  end
  # [END view_bucket_iam_members]
end

def add_bucket_iam_member project_id:, bucket_name:, role:, member:
  # [START add_bucket_iam_member]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Your Google Cloud Storage bucket name"
  # role        = "Bucket-level IAM role"
  # member      = "Bucket-level IAM member"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project_id: project_id
  bucket = storage.bucket bucket_name

  bucket.policy do |policy|
    policy.add role, member
  end

  puts "Added #{member} with role #{role} to #{bucket_name}"
  # [END add_bucket_iam_member]
end

def remove_bucket_iam_member project_id:, bucket_name:, role:, member:
  # [START remove_bucket_iam_member]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Your Google Cloud Storage bucket name"
  # role        = "Bucket-level IAM role"
  # member      = "Bucket-level IAM member"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project_id: project_id
  bucket = storage.bucket bucket_name

  bucket.policy do |policy|
    policy.remove role, member
  end

  puts "Removed #{member} with role #{role} from #{bucket_name}"
  # [END remove_bucket_iam_member]
end

def run_sample arguments
  command    = arguments.shift
  project_id = ENV["GOOGLE_CLOUD_PROJECT"]

  case command
  when "view_bucket_iam_members"
    view_bucket_iam_members project_id:  project_id,
                            bucket_name: arguments.shift
  when "add_bucket_iam_member"
    add_bucket_iam_member project_id:  project_id,
                          bucket_name: arguments.shift,
                          role:        arguments.shift,
                          member:      arguments.shift
  when "remove_bucket_iam_member"
    remove_bucket_iam_member project_id:  project_id,
                             bucket_name: arguments.shift,
                             role:        arguments.shift,
                             member:      arguments.shift
  else
    puts <<~USAGE
      Usage: bundle exec ruby iam.rb [command] [arguments]

      Commands:
        view_bucket_iam_members  <bucket>                         View bucket-level IAM members
        add_bucket_iam_member    <bucket> <iam_role> <iam_member> Add a bucket-level IAM member
        remove_bucket_iam_member <bucket> <iam_role> <iam_member> Remove a bucket-level IAM member

      Environment variables:
        GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    USAGE
  end
end

if $PROGRAM_NAME == __FILE__
  run_sample ARGV
end
