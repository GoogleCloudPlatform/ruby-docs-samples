# Copyright 2020 Google LLC
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

require "google/cloud/monitoring"

def quickstart project_id:, metric_label:
  # [START monitoring_quickstart]
  # Your Google Cloud Platform project ID
  # project_id = "YOUR_PROJECT_ID"

  # Example metric label
  # metric_label = "my-value"

  # Instantiates a client
  metric_service_client = Google::Cloud::Monitoring::Metric.new
  project_path = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path project_id

  series = Google::Monitoring::V3::TimeSeries.new
  series.metric = Google::Api::Metric.new type:   "custom.googleapis.com/my_metric",
                                          labels: { "my_key" => metric_label }

  resource = Google::Api::MonitoredResource.new type: "global"
  resource.labels["project_id"] = project_id
  series.resource = resource

  point = Google::Monitoring::V3::Point.new
  point.value = Google::Monitoring::V3::TypedValue.new double_value: 3.14
  now = Time.now
  end_time = Google::Protobuf::Timestamp.new seconds: now.to_i, nanos: now.usec
  point.interval = Google::Monitoring::V3::TimeInterval.new end_time: end_time
  series.points << point

  metric_service_client.create_time_series project_path, [series]

  puts "Successfully wrote time series."
  # [END monitoring_quickstart]
end

# Run
quickstart project_id: ARGV.shift, metric_label: ARGV.shift if $PROGRAM_NAME == __FILE__
