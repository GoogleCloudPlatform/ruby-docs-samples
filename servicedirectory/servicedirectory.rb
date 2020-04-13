# Copyright 2020 Google, Inc
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
#
# Note: Code samples in this file set constants which cannot be set inside
#       method definitions in Ruby. To allow for this, code snippets in this
#       sample are wrapped in global lambdas.

$create_namespace = lambda do |project:, location:, namespace:|
  # [START servicedirectory_create_namespace]
  # project   = "Your Google Cloud project ID"
  # location  = "The Google Cloud region containing the new namespace"
  # namespace = "The name of the namespace you are creating"

  require "google/cloud/service_directory/v1beta1"
  ServiceDirectory = Google::Cloud::ServiceDirectory::V1beta1

  # Initialize the client
  client = ServiceDirectory::RegistrationService::Client.new

  # The parent path of the namespace
  parent = ServiceDirectory::RegistrationService::Paths.location_path(
    project: project, location: location)

  # Use the Service Directory API to create the namespace
  request = ServiceDirectory::CreateNamespaceRequest.new(
    parent: parent,
    namespace_id: namespace)
  response = client.create_namespace request
  puts "Created namespace: #{response.name}"
  # [END servicedirectory_create_namespace]
end

$delete_namespace = lambda do |project:, location:, namespace:|
  # [START servicedirectory_delete_namespace]
  # project   = "Your Google Cloud project ID"
  # location  = "The Google Cloud region containing the namespace"
  # namespace = "The name of the namespace"

  require "google/cloud/service_directory/v1beta1"
  ServiceDirectory = Google::Cloud::ServiceDirectory::V1beta1

  # Initialize the client
  client = ServiceDirectory::RegistrationService::Client.new

  # The path of the namespace
  namespace_name = ServiceDirectory::RegistrationService::Paths.namespace_path(
    project: project, location: location, namespace: namespace)

  # Use the Service Directory API to delete the namespace
  request = ServiceDirectory::DeleteNamespaceRequest.new(
    name: namespace_name
  )
  client.delete_namespace request
  puts "Deleted namespace: #{namespace_name}"
  # [END servicedirectory_delete_namespace]
end

$create_service = lambda do |project:, location:, namespace:, service:|
  # [START servicedirectory_create_service]
  # project   = "Your Google Cloud project ID"
  # location  = "The Google Cloud region containing the namespace"
  # namespace = "The name of the parent namespace"
  # service   = "The name of the service you are creating"

  require "google/cloud/service_directory/v1beta1"
  ServiceDirectory = Google::Cloud::ServiceDirectory::V1beta1

  # Initialize the client
  client = ServiceDirectory::RegistrationService::Client.new

  # The parent path of the service
  parent = ServiceDirectory::RegistrationService::Paths.namespace_path(
    project: project, location: location, namespace: namespace)

  # Use the Service Directory API to create the service
  request = ServiceDirectory::CreateServiceRequest.new(
    parent:     parent,
    service_id: service
  )
  response = client.create_service request
  puts "Created service: #{response.name}"
  # [END servicedirectory_create_service]
end

$delete_service = lambda do |project:, location:, namespace:, service:|
  # [START servicedirectory_delete_service]
  # project   = "Your Google Cloud project ID"
  # location  = "The Google Cloud region containing the namespace"
  # namespace = "The name of the parent namespace"
  # service   = "The name of the service"

  require "google/cloud/service_directory/v1beta1"
  ServiceDirectory = Google::Cloud::ServiceDirectory::V1beta1

  # Initialize the client
  client = ServiceDirectory::RegistrationService::Client.new

  # The path of the service
  service_path = ServiceDirectory::RegistrationService::Paths.service_path(
    project:   project,
    location:  location,
    namespace: namespace,
    service:   service
  )

  # Use the Service Directory API to delete the service
  request = ServiceDirectory::DeleteServiceRequest.new(
    name: service_path
  )
  client.delete_service request
  puts "Deleted service: #{service_path}"
  # [END servicedirectory_delete_service]
end

$create_endpoint = lambda do |project:, location:, namespace:, service:, endpoint:|
  # [START servicedirectory_create_endpoint]
  # project   = "Your Google Cloud project ID"
  # location  = "The Google Cloud region containing the namespace"
  # namespace = "The name of the parent namespace"
  # service   = "The name of the parent service"
  # endpoint  = "The name of the endpoint you are creating"

  require "google/cloud/service_directory/v1beta1"
  ServiceDirectory = Google::Cloud::ServiceDirectory::V1beta1

  # Initialize the client
  client = ServiceDirectory::RegistrationService::Client.new

  # The parent path of the endpoint
  parent = ServiceDirectory::RegistrationService::Paths.service_path(
    project: project,
    location: location,
    namespace: namespace,
    service: service
  )

  # Set the IP Address and Port on the Endpoint
  endpoint_data = ServiceDirectory::Endpoint.new(
    address: "10.0.0.1",
    port:    443
  )

  # Use the Service Directory API to create the endpoint
  request = ServiceDirectory::CreateEndpointRequest.new(
    parent:      parent,
    endpoint_id: endpoint,
    endpoint:    endpoint_data
  )
  response = client.create_endpoint request
  puts "Created endpoint: #{response.name}"
  # [END servicedirectory_create_endpoint]
end

$delete_endpoint = lambda do |project:, location:, namespace:, service:, endpoint:|
  # [START servicedirectory_delete_endpoint]
  # project   = "Your Google Cloud project ID"
  # location  = "The Google Cloud region containing the namespace"
  # namespace = "The name of the parent namespace"
  # service   = "The name of the parent service"
  # endpoint  = "The name of the endpoint"

  require "google/cloud/service_directory/v1beta1"
  ServiceDirectory = Google::Cloud::ServiceDirectory::V1beta1

  # Initialize the client
  client = ServiceDirectory::RegistrationService::Client.new

  # The path of the endpoint
  endpoint_path = ServiceDirectory::RegistrationService::Paths.endpoint_path(
    project:   project,
    location:  location,
    namespace: namespace,
    service:   service,
    endpoint:  endpoint
  )

  # Use the Service Directory API to delete the endpoint
  request = ServiceDirectory::DeleteEndpointRequest.new(
    name: endpoint_path
  )
  client.delete_endpoint request
  puts "Deleted endpoint: #{endpoint_path}"
  # [END servicedirectory_delete_endpoint]
end

$resolve_service = lambda do |project:, location:, namespace:, service:|
  # [START servicedirectory_resolve_service]
  # project   = "Your Google Cloud project ID"
  # location  = "The Google Cloud region containing the namespace"
  # namespace = "The name of the parent namespace"
  # service   = "The name of the service"

  require "google/cloud/service_directory/v1beta1"
  ServiceDirectory = Google::Cloud::ServiceDirectory::V1beta1

  # Initialize the client
  client = ServiceDirectory::LookupService::Client.new

  # The name of the service
  service_path = ServiceDirectory::LookupService::Paths.service_path(
    project:   project,
    location:  location,
    namespace: namespace,
    service:   service
  )

  # Use the Service Directory API to resolve the service
  request = ServiceDirectory::ResolveServiceRequest.new(
    name: service_path
  )
  response = client.resolve_service request
  puts "Resolved service: #{response.service.name}"
  puts "Endpoints: "
  response.service.endpoints.each do |endpoint|
    puts "#{endpoint.name} #{endpoint.address} #{endpoint.port}"
  end
  # [END servicedirectory_resolve_service]
end


if $PROGRAM_NAME == __FILE__
  project = ENV["GOOGLE_CLOUD_PROJECT"]
  command    = ARGV.shift

  case command
  when "create_namespace"
    $create_namespace.call(
      project:   project,
      location:  ARGV.shift,
      namespace: ARGV.shift
    )
  when "delete_namespace"
    $delete_namespace.call(
      project:   project,
      location:  ARGV.shift,
      namespace: ARGV.shift
    )
  when "create_service"
    $create_service.call(
      project:   project,
      location:  ARGV.shift,
      namespace: ARGV.shift,
      service:   ARGV.shift
    )
  when "delete_service"
    $delete_service.call(
      project:   project,
      location:  ARGV.shift,
      namespace: ARGV.shift,
      service:   ARGV.shift
    )
  when "create_endpoint"
    $create_endpoint.call(
      project:   project,
      location:  ARGV.shift,
      namespace: ARGV.shift,
      service:   ARGV.shift,
      endpoint:  ARGV.shift
    )
  when "delete_endpoint"
    $delete_endpoint.call(
      project:   project,
      location:  ARGV.shift,
      namespace: ARGV.shift,
      service:   ARGV.shift,
      endpoint:  ARGV.shift
    )
  when "resolve_service"
    $resolve_service.call(
      project:   project,
      location:  ARGV.shift,
      namespace: ARGV.shift,
      service:   ARGV.shift
    )
  else
    puts <<~USAGE
      Usage: bundle exec ruby servicedirectory.rb [command] [arguments]

      Commands:
        create_namespace    <location> <namespace>
        delete_namespace    <location> <namespace>
        create_service      <location> <namespace> <service>
        delete_service      <location> <namespace> <service>
        create_endpoint     <location> <namespace> <service> <endpoint>
        delete_endpoint     <location> <namespace> <service> <endpoint>
        resolve_service     <location> <namespace> <service>

      Environment variables:
        GOOGLE_CLOUD_PROJECT must be set to your Google Cloud Project ID
    USAGE
  end

end
