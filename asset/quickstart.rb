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

def export_assets project_id:, dump_file_path:
  # [START asset_quickstart_export_assets]
  require "google/cloud/asset"

  asset_service_client = Google::Cloud::Asset.new version: :v1beta1
  # project_id = 'YOUR_PROJECT_ID'
  # Assets dump file path, e.g.: gs://[YOUR_BUCKET]/[YOUR_ASSETS_FILE]
  # dump_file_path = 'YOUR_ASSET_DUMP_FILE_PATH'
  formatted_parent =
    Google::Cloud::Asset::V1beta1::AssetServiceClient.project_path(
      project_id
    )
  output_config = Google::Cloud::Asset::V1beta1::OutputConfig.new(
    gcs_destination: Google::Cloud::Asset::V1beta1::GcsDestination.new(
      uri: dump_file_path
    )
  )

  operation = asset_service_client.export_assets(
    formatted_parent, output_config
  ) do |op|
    # Handle the error.
    raise op.results.message if op.error?
  end

  operation.wait_until_done!
  # Do things with the result
  # [END asset_quickstart_export_assets]
end

def batch_get_history project_id:, asset_names:
  # [START asset_quickstart_batch_get_assets_history]
  require "google/cloud/asset"

  # project_id = 'YOUR_PROJECT_ID'
  # asset names, e.g.: //storage.googleapis.com/[YOUR_BUCKET_NAME]
  # asset_names = [ASSET_NAMES, COMMMA_DELIMTTED]
  formatted_parent =
    Google::Cloud::Asset::V1beta1::AssetServiceClient.project_path project_id

  content_type = :RESOURCE
  read_time_window = Google::Cloud::Asset::V1beta1::TimeWindow.new(
    start_time: Google::Protobuf::Timestamp.new(seconds: Time.now.getutc.to_i)
  )

  asset_service_client = Google::Cloud::Asset.new version: :v1beta1
  response = asset_service_client.batch_get_assets_history(
    formatted_parent, content_type, read_time_window, asset_names: asset_names
  )
  # Do things with the response
  puts response
  # [END asset_quickstart_batch_get_assets_history]
end
