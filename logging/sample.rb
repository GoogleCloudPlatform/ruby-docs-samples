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

def create_logging_client
  # [START create_logging_client]
  require "google/cloud"

  gcloud  = Google::Cloud.new "my-gcp-project-id"
  logging = gcloud.logging
  # [END create_logging_client]
end

def list_log_sinks
  # [START list_log_sinks]
  require "google/cloud"

  gcloud  = Google::Cloud.new "my-gcp-project-id"
  logging = gcloud.logging

  logging.sinks.each do |sink|
    puts "#{sink.name}: #{sink.filter} -> #{sink.destination}"
  end
  # [END list_log_sinks]
end

def create_log_sink
  # [START create_log_sink]
  require "google/cloud"

  gcloud  = Google::Cloud.new "my-gcp-project-id"
  logging = gcloud.logging
  storage = gcloud.storage
  bucket  = storage.create_bucket "my-logs-bucket"

  # Grant owner permission to Cloud Logging service
  email = "cloud-logs@google.com"
  bucket.acl.add_owner "group-#{email}"

  sink = logging.create_sink "my-sink", "storage.googleapis.com/#{bucket.id}"
  # [END create_log_sink]
end

def update_log_sink
  # [START update_log_sink]
  require "google/cloud"

  gcloud  = Google::Cloud.new "my-gcp-project-id"
  logging = gcloud.logging
  storage = gcloud.storage
  bucket  = storage.bucket "new-destination-bucket"
  sink    = logging.sink "my-sink"

  sink.destination = "storage.googleapis.com/#{bucket.id}"

  sink.save
  # [END update_log_sink]
end

def delete_log_sink
  # [START delete_log_sink]
  require "google/cloud"

  gcloud  = Google::Cloud.new "my-gcp-project-id"
  logging = gcloud.logging

  sink = logging.sink "my-sink"
  sink.delete
  # [END delete_log_sink]
end

def list_log_entries
  # [START list_log_entries]
  require "google/cloud"

  gcloud  = Google::Cloud.new "my-gcp-project-id"
  logging = gcloud.logging
  entries = logging.entries filter: 'resource.type = "gae_app"'

  entries.each do |entry|
    puts "[#{entry.timestamp}] #{entry.log_name} #{entry.payload.inspect}"
  end
  # [END list_log_entries]
end

def write_log_entry
  # [START write_log_entry]
  require "google/cloud"

  gcloud  = Google::Cloud.new "my-gcp-project-id"
  logging = gcloud.logging

  entry = logging.entry
  entry.log_name = "my_application_log"
  entry.payload  = "Log message"
  entry.severity = :NOTICE
  entry.resource.type = "gae_app"
  entry.resource.labels[:module_id] = "default"
  entry.resource.labels[:version_id] = "20160101t163030"

  logging.write_entries entry
  # [END write_log_entry]
end

def delete_log
  # [START delete_log]
  require "google/cloud"

  gcloud  = Google::Cloud.new "my-gcp-project-id"
  logging = gcloud.logging

  logging.delete_log "my_application_log"
  # [END delete_log]
end

def write_log_entry_using_ruby_logger
  # [START write_log_entry_using_ruby_logger]
  require "google/cloud"

  gcloud   = Google::Cloud.new "my-gcp-project-id"
  logging  = gcloud.logging
  resource = logging.resource "gae_app", module_id: "default",
                                         version_id: "20160101t163030"

  logger = logging.logger "my_application_log", resource

  logger.info "Log message"
  # [END write_log_entry_using_ruby_logger]
end
