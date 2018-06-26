# Copyright 2018 Google, Inc
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

def detect_pdf_gcs gcs_source_uri:, gcs_destination_uri:, project_id:
  # [START vision_async_detect_document_ocr]
  # project_id = "Your Google Cloud project ID"
  # gcs_source_uri = "Google Cloud Storage URI, eg. 'gs://my-bucket/example.pdf'"
  # gcs_destination_uri = "Google Cloud Storage URI, eg. 'gs://my-bucket/prefix_'"

  require "google/cloud/vision"
  require "google/cloud/storage"

  vision_client = Google::Cloud::Vision::V1.new

  # Supported mime_types are: 'application/pdf' and 'image/tiff'
  input_config = {
    gcs_source: { uri: gcs_source_uri },
    mime_type:  "application/pdf"
  }

  output_config = {
    gcs_destination: { uri: gcs_destination_uri },
    batch_size:      2  # number of pages to group per json output file
  }

  async_request = {
    input_config:  input_config,
    features:      [{ type: "DOCUMENT_TEXT_DETECTION" }],
    output_config: output_config
  }

  operation = vision_client.async_batch_annotate_files [async_request]

  puts "Waiting for the operation to finish."
  operation.wait_until_done!

  # Once the request has completed and the output has been
  # written to GCS, we can list all the output files.
  storage_client = Google::Cloud::Storage.new

  bucket_name, prefix = gcs_destination_uri.match("gs://([^/]+)/(.+)").captures
  bucket = storage_client.bucket bucket_name

  # List objects with the given prefix.
  puts "Output files:"
  blob_list = bucket.files prefix: prefix
  blob_list.each do |file|
    puts file.name
  end

  # Process the first output file from GCS.
  # Since we specified a batch_size of 2, the first response contains
  # the first two pages of the input file.
  output = blob_list[0]
  json_string = output.download
  response = JSON.parse(json_string.string)

  # The actual response for the first page of the input file.
  first_page_response = response["responses"][0]
  annotation = first_page_response["fullTextAnnotation"]

  # Here we print the full text from the first page.
  # The response contains more information:
  # annotation/pages/blocks/paragraphs/words/symbols
  # including confidence scores and bounding boxes
  puts "Full text:\n#{annotation['text']}"
  # [END vision_async_detect_document_ocr]
end

if __FILE__ == $PROGRAM_NAME
  project_id = ENV["GOOGLE_CLOUD_PROJECT"]

  if ARGV.size == 2
    detect_pdf_gcs gcs_source_uri:      ARGV.shift,
                   gcs_destination_uri: ARGV.shift,
                   project_id:          project_id
  else
    puts <<-usage
Usage: ruby detect_pdf.rb [document gcs file path] [output gcs file path]

Example:
  ruby detect_pdf.rb gs://my-bucket/example.pdf gs://my-bucket/prefix_
    usage
  end
end
