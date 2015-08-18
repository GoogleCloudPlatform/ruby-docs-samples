#!/usr/bin/ruby
# Copyright 2015 Google, Inc.
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

# A short sample demonstrating making an authenticated api request.
#
# Specifically, it creates a Service object to the Google Cloud Storage api, and
# uses Application Default Credentials to authenticate.
#
# [START all]
require "google/apis/storage_v1"
require "googleauth"

# Alias the module for greater brevity
Storage = Google::Apis::StorageV1

def create_storage_service
  storage = Storage::StorageService.new
  storage.authorization = Google::Auth.get_application_default(
    [Storage::AUTH_DEVSTORAGE_READ_ONLY]
  )

  storage
end

def list_buckets(project_id)
  storage = create_storage_service
  storage.list_buckets(project_id).items.each do |bucket|
    puts bucket.name
  end
end

if __FILE__ == $PROGRAM_NAME
  abort "Usage: #{__FILE__} <project-id>" if ARGV.length < 1
  list_buckets(ARGV[0])
end

# [END all]
