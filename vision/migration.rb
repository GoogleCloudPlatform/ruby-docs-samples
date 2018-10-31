# Copyright 2018 Google LLC
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

# [START vision_migration_require]
# Imports the Google Cloud client library
require "google/cloud/vision"
# [END vision_migration_require]

# [START vision_migration_client_old]
# Instantiates a client
project_id = "YOUR_PROJECT_ID"
vision = Google::Cloud::Vision.new project: project_id
# [END vision_migration_client_old]

# [START vision_migration_client_new]
# Instantiates a client
vision = Google::Cloud::Vision.new
# [END vision_migration_client_new]

# [START vision_migration_client_version]
# Instantiates a client with a specified version
vision = Google::Cloud::Vision.new version: :v1
# [END vision_migration_client_version]

# [START vision_migration_labels_local_old]
project_id = "YOUR_PROJECT_ID"
vision = Google::Cloud::Vision.new project: project_id
file_name = "./resources/cat.jpg"
max_results = 15 # optional, defaults to 100
labels = vision.image(file_name).labels max_results

puts "Labels:"
labels.each do |label|
  puts label.description
end
# [END vision_migration_labels_local_old]

# [START vision_migration_labels_local_new]
image_annotator_client = Google::Cloud::Vision.new
file_name = "./resources/cat.jpg"
image_content = File.binread file_name
image = { content: image_content }
type = :LABEL_DETECTION
max_results = 15 # optional, defaults to 10
features_element = { type: type, max_results: max_results }
features = [features_element]
request = { image: image, features: features }
# request == {
#               image: {
#                 content: (File.binread "./resources/cat.jpg")
#               },
#               features: [
#                 {
#                   type: :LABEL_DETECTION,
#                   max_results: 15
#                 }
#               ]
#             }

requests = [request]
response = image_annotator_client.batch_annotate_images(requests)

puts "Labels:"
response.responses.each do |res|
  res.label_annotations.each do |label|
    puts label.description
  end
end
# [END vision_migration_labels_local_new]

# [START vision_migration_labels_storage_old]
project_id = "YOUR_PROJECT_ID"
vision = Google::Cloud::Vision.new project: project_id
storage_uri = "gs://gapic-toolkit/President_Barack_Obama.jpg"
max_results = 15 # optional, defaults to 100
labels = vision.image(storage_uri).labels max_results

puts "Labels:"
labels.each do |label|
  puts label.description
end
# [END vision_migration_labels_storage_old]

# [START vision_migration_labels_storage_new]
image_annotator_client = Google::Cloud::Vision.new
storage_uri = "gs://gapic-toolkit/President_Barack_Obama.jpg"
source = { gcs_image_uri: storage_uri }
image = { source: source }
type = :LABEL_DETECTION
max_results = 15 # optional, defaults to 10
features_element = { type: type, max_results: max_results }
features = [features_element]
request = { image: image, features: features }
# request == {
#               image: {
#                 source: {
#                   gcs_image_uri: "gs://gapic-toolkit/President_Barack_Obama.jpg"
#                 }
#               },
#               features: [
#                 {
#                   type: :LABEL_DETECTION,
#                   max_results: 15
#                 }
#               ]
#             }

requests = [request]
response = image_annotator_client.batch_annotate_images(requests)

puts "Labels:"
response.responses.each do |res|
  res.label_annotations.each do |label|
    puts label.description
  end
end
# [END vision_migration_labels_storage_new]

# [START vision_migration_asynchronous]
storage_uri = "gs://my-bucket/document-name.pdf"
gcs_source = { uri: storage_uri }
input_config = { gcs_source: gcs_source, mime_type: "application/pdf" }
type = :DOCUMENT_TEXT_DETECTION
max_results = 15 # optional, defaults to 10
features_element = { type: type, max_results: max_results }
features = [features_element]
destination_uri = "gs://my-bucket/prefix"
destination = { uri: destination_uri }

# number of response protos per output file
batch_size = 1 # optional, defaults to 20
output_config = { gcs_destination: destination, batch_size: batch_size }
request = { input_config: input_config, features: features, output_config: output_config }
# request == {
#               input_config: {
#                 gcs_source: {
#                   uri: "gs://my-bucket/document-name.pdf"
#                 },
#                 mime_type: "application/pdf"
#               },
#               output_config: {
#                 gcs_destination: {
#                   uri: "gs://my-bucket/prefix"
#                 },
#                 batch_size: 1
#               }
#               features: [
#                 {
#                   type: :DOCUMENT_TEXT_DETECTION,
#                   max_results: 15
#                 }
#               ]
#             }

requests = [request]
operation = vision.async_batch_annotate_files(requests)
operation.wait_until_done!
# [END vision_migration_asynchronous]
