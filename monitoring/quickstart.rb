require "google/cloud/monitoring"

def quickstart
  # [START monitoring_quickstart]
  # Your Google Cloud Platform project ID
  project_id = "YOUR_PROJECT_ID"

  # Instantiates a client
  metric_service_client = Google::Cloud::Monitoring::Metric.new
  project_path = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path project_id

  series = Google::Monitoring::V3::TimeSeries.new
  series.metric = Google::Api::Metric.new type: "custom.googleapis.com/my_metric"

  resource = Google::Api::MonitoredResource.new type: "gce_instance"
  resource.labels["instance_id"] = "1234567890123456789"
  resource.labels["zone"] = "us-central1-f"
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
quickstart
