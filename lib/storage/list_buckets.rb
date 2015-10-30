#!/usr/bin/env ruby

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

module Samples
  module Storage
    # A short sample demonstrating making an authenticated api request.
    #
    # Specifically, it creates a Service object to the Google Cloud Storage api,
    # and uses Application Default Credentials to authenticate.
    class ListBuckets
      # [START list_buckets]
      require "google/apis/storage_v1"

      # Alias the Google Cloud Storage module
      Storage = Google::Apis::StorageV1

      def list_buckets project_id
        # Create the storage service object, used to access the storage api.
        storage = Storage::StorageService.new
        # Have the service object use the application default credentials to
        # auth, which infers credentials from the environment.
        storage.authorization = Google::Auth.get_application_default(
          # Set the credentials to have a readonly scope to the storage service.
          Storage::AUTH_DEVSTORAGE_READ_ONLY
        )

        # Make the api call to list buckets owned by the default credentials.
        storage.list_buckets(project_id).items.each do |bucket|
          # Print out each bucket name.
          puts bucket.name
        end
      end
      # [END list_buckets]
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  project_id = ARGV.shift

  Samples::Storage::ListBuckets.new.list_buckets project_id
end
