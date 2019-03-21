require "google/cloud/monitoring"

def create_metric_descriptor project_id:
  # Random suffix for metric type to avoid collisions with other runs
  random_suffix = rand(36**10).to_s 36

  # [START monitoring_create_metric]
  client = Google::Cloud::Monitoring::Metric.new
  project_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path project_id

  descriptor = Google::Api::MetricDescriptor.new(
    type:        "custom.googleapis.com/my_metric#{random_suffix}",
    metric_kind: Google::Api::MetricDescriptor::MetricKind::GAUGE,
    value_type:  Google::Api::MetricDescriptor::ValueType::DOUBLE,
    description: "This is a simple example of a custom metric."
  )

  result = client.create_metric_descriptor project_name, descriptor
  p "Created #{result.name}"
  p result
  # [END monitoring_create_metric]
end

def delete_metric_descriptor descriptor_name:
  # [START monitoring_delete_metric]
  client = Google::Cloud::Monitoring::Metric.new
  client.delete_metric_descriptor descriptor_name
  p "Deleted metric descriptor #{descriptor_name}."
  # [END monitoring_delete_metric]
end

def write_time_series project_id:
  # [START monitoring_write_timeseries]
  client = Google::Cloud::Monitoring::Metric.new
  project_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path project_id

  # Random suffix for metric type to avoid collisions with other runs
  random_suffix = rand(36**10).to_s 36

  series = Google::Monitoring::V3::TimeSeries.new
  metric = Google::Api::Metric.new type: "custom.googleapis.com/my_metric#{random_suffix}"
  series.metric = metric

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

  client.create_time_series project_name, [series]
  p "Time series created : #{metric.type}"
  # [END monitoring_write_timeseries]
end

def list_time_series project_id:
  # [START monitoring_read_timeseries_simple]
  client = Google::Cloud::Monitoring::Metric.new
  project_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path project_id

  interval = Google::Monitoring::V3::TimeInterval.new
  now = Time.now
  interval.end_time = Google::Protobuf::Timestamp.new seconds: now.to_i, nanos: now.usec
  interval.start_time = Google::Protobuf::Timestamp.new seconds: now.to_i - 300, nanos: now.usec

  results = client.list_time_series(
    project_name,
    'metric.type = "compute.googleapis.com/instance/cpu/utilization"',
    interval,
    Google::Monitoring::V3::ListTimeSeriesRequest::TimeSeriesView::FULL
  )
  results.each do |result|
    p result
  end
  # [END monitoring_read_timeseries_simple]
end

def list_time_series_header project_id:
  # [START monitoring_read_timeseries_fields]
  client = Google::Cloud::Monitoring::Metric.new
  project_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path project_id

  interval = Google::Monitoring::V3::TimeInterval.new
  now = Time.now
  interval.end_time = Google::Protobuf::Timestamp.new seconds: now.to_i, nanos: now.usec
  interval.start_time = Google::Protobuf::Timestamp.new seconds: now.to_i - 300, nanos: now.usec

  results = client.list_time_series(
    project_name,
    'metric.type = "compute.googleapis.com/instance/cpu/utilization"',
    interval,
    Google::Monitoring::V3::ListTimeSeriesRequest::TimeSeriesView::HEADERS
  )
  results.each do |result|
    p result
  end
  # [END monitoring_read_timeseries_fields]
end

def list_time_series_aggregate project_id:
  # [START monitoring_read_timeseries_align]
  client = Google::Cloud::Monitoring::Metric.new
  project_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path project_id

  interval = Google::Monitoring::V3::TimeInterval.new
  now = Time.now
  interval.end_time = Google::Protobuf::Timestamp.new seconds: now.to_i, nanos: now.usec
  interval.start_time = Google::Protobuf::Timestamp.new seconds: now.to_i - 300, nanos: now.usec

  aggregation = Google::Monitoring::V3::Aggregation.new(
    alignment_period:   { seconds: 300 },
    per_series_aligner: Google::Monitoring::V3::Aggregation::Aligner::ALIGN_MEAN
  )

  results = client.list_time_series(
    project_name,
    'metric.type = "compute.googleapis.com/instance/cpu/utilization"',
    interval,
    Google::Monitoring::V3::ListTimeSeriesRequest::TimeSeriesView::FULL,
    aggregation: aggregation
  )
  results.each do |result|
    p result
  end

  # [END monitoring_read_timeseries_align]
end

def list_time_series_reduce project_id:
  # [START monitoring_read_timeseries_reduce]
  client = Google::Cloud::Monitoring::Metric.new
  project_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path project_id

  interval = Google::Monitoring::V3::TimeInterval.new
  now = Time.now
  interval.end_time = Google::Protobuf::Timestamp.new seconds: now.to_i, nanos: now.usec
  interval.start_time = Google::Protobuf::Timestamp.new seconds: now.to_i - 300, nanos: now.usec

  aggregation = Google::Monitoring::V3::Aggregation.new(
    alignment_period:     { seconds: 300 },
    per_series_aligner:   Google::Monitoring::V3::Aggregation::Aligner::ALIGN_MEAN,
    cross_series_reducer: Google::Monitoring::V3::Aggregation::Reducer::REDUCE_MEAN,
    group_by_fields:      ["resource.zone"]
  )

  results = client.list_time_series(
    project_name,
    'metric.type = "compute.googleapis.com/instance/cpu/utilization"',
    interval,
    Google::Monitoring::V3::ListTimeSeriesRequest::TimeSeriesView::FULL,
    aggregation: aggregation
  )
  results.each do |result|
    p result
  end

  # [END monitoring_read_timeseries_reduce]
end

def list_metric_descriptors project_id:
  # [START monitoring_list_descriptors]
  client = Google::Cloud::Monitoring::Metric.new
  project_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path project_id
  results = client.list_metric_descriptors project_name
  results.each do |descriptor|
    p descriptor.type
  end
  # [END monitoring_list_descriptors]
end

def list_monitored_resources project_id:
  # [START monitoring_list_resources]
  client = Google::Cloud::Monitoring::Metric.new
  project_name = Google::Cloud::Monitoring::V3::MetricServiceClient.project_path project_id
  results = client.list_monitored_resource_descriptors project_name
  results.each do |descriptor|
    p descriptor.type
  end
  # [END monitoring_list_resources]
end

def get_monitored_resource_descriptor project_id:, resource_type:
  # [START monitoring_get_resource]
  client = Google::Cloud::Monitoring::Metric.new
  resource_path = Google::Cloud::Monitoring::V3::MetricServiceClient.monitored_resource_descriptor_path(
    project_id,
    resource_type
  )

  result = client.get_monitored_resource_descriptor resource_path
  p result
  # [END monitoring_get_resource]
end

def get_metric_descriptor metric_name:
  # [START monitoring_get_descriptor]
  client = Google::Cloud::Monitoring::Metric.new
  descriptor = client.get_metric_descriptor metric_name
  p descriptor
  # [END monitoring_get_descriptor]
end

if $PROGRAM_NAME == __FILE__
  case ARGV.shift
  when "create_metric_descriptor"
    create_metric_descriptor project_id: ARGV.shift
  when "delete_metric_descriptor"
    delete_metric_descriptor descriptor_name: ARGV.shift
  when "write_time_series"
    write_time_series project_id: ARGV.shift
  when "list_time_series"
    list_time_series project_id: ARGV.shift
  when "list_time_series_header"
    list_time_series_header project_id: ARGV.shift
  when "list_time_series_aggregate"
    list_time_series_aggregate project_id: ARGV.shift
  when "list_time_series_reduce"
    list_time_series_reduce project_id: ARGV.shift
  when "list_metric_descriptors"
    list_metric_descriptors project_id: ARGV.shift
  when "list_monitored_resources"
    list_monitored_resources project_id: ARGV.shift
  when "get_monitored_resource_descriptor"
    get_monitored_resource_descriptor project_id: ARGV.shift, resource_type: ARGV.shift
  when "get_metric_descriptor"
    get_metric_descriptor metric_name: ARGV.shift
  else
    puts <<~USAGE
      Usage: bundle exec ruby metrics.rb [command] [arguments]

      Commands:
        create_metric_descriptor                     <project_id>
        delete_metric_descriptor                     <descriptor_name>
        write_time_series                            <project_id>
        list_time_series                             <project_id>
        list_time_series_header                      <project_id>
        list_time_series_aggregate                   <project_id>
        list_time_series_reduce                      <project_id>
        list_metric_descriptors                      <project_id>
        list_monitored_resources                     <project_id>
        get_monitored_resource_descriptor            <project_id> <resource_type>
        get_metric_descriptor                        <metric_name>
    USAGE
  end
end
