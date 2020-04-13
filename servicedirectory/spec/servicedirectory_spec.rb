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

require "rspec"
require "google/cloud/service_directory/v1beta1"
require_relative "../servicedirectory"

describe "Service Directory API Test" do
  ServiceDirectory = Google::Cloud::ServiceDirectory::V1beta1

  def create_namespace project:, location:, namespace:
    client = ServiceDirectory::RegistrationService::Client.new
    location_path = ServiceDirectory::RegistrationService::Paths.location_path(
      project:  project,
      location: location
    )
    request = ServiceDirectory::CreateNamespaceRequest.new(
      parent:       location_path,
      namespace_id: namespace
    )
    client.create_namespace request
  end

  def get_namespace project:, location:, namespace:
    client = ServiceDirectory::RegistrationService::Client.new
    namespace_path = ServiceDirectory::RegistrationService::Paths.namespace_path(
      project:   project,
      location:  location,
      namespace: namespace
    )
    request = ServiceDirectory::GetNamespaceRequest.new(
      name: namespace_path
    )
    client.get_namespace request
  end

  def delete_namespace namespace_path:
    client = ServiceDirectory::RegistrationService::Client.new
    request = ServiceDirectory::DeleteNamespaceRequest.new(
      name: namespace_path
    )
    client.delete_namespace request
  end

  def create_service project:, location:, namespace:, service:
    client = ServiceDirectory::RegistrationService::Client.new
    namespace_path = ServiceDirectory::RegistrationService::Paths.namespace_path(
      project:   project,
      location:  location,
      namespace: namespace
    )
    request = ServiceDirectory::CreateServiceRequest.new(
      parent:     namespace_path,
      service_id: service
    )
    client.create_service request
  end

  def get_service project:, location:, namespace:, service:
    client = ServiceDirectory::RegistrationService::Client.new
    service_path = ServiceDirectory::RegistrationService::Paths.service_path(
      project:   project,
      location:  location,
      namespace: namespace,
      service:   service
    )
    request = ServiceDirectory::GetServiceRequest.new(
      name: service_path
    )
    client.get_service request
  end

  def create_endpoint project:, location:, namespace:, service:, endpoint:
    client = ServiceDirectory::RegistrationService::Client.new
    service_path = ServiceDirectory::RegistrationService::Paths.service_path(
      project:   project,
      location:  location,
      namespace: namespace,
      service:   service
    )
    endpoint_data = ServiceDirectory::Endpoint.new(
      address: "10.0.0.1",
      port:    443
    )
    request = ServiceDirectory::CreateEndpointRequest.new(
      parent:      service_path,
      endpoint_id: endpoint,
      endpoint:    endpoint_data
    )
    client.create_endpoint request
  end

  def get_endpoint project:, location:, namespace:, service:, endpoint:
    client = ServiceDirectory::RegistrationService::Client.new
    endpoint_path = ServiceDirectory::RegistrationService::Paths.endpoint_path(
      project:   project,
      location:  location,
      namespace: namespace,
      service:   service,
      endpoint:  endpoint
    )
    request = ServiceDirectory::GetEndpointRequest.new(
      name: endpoint_path
    )
    client.get_endpoint request
  end

  before :each do
    @project   = ENV["GOOGLE_CLOUD_PROJECT"]
    @location  = "us-central1"
    @namespace = "ruby-test-namespace-#{Time.now.to_i}"
    @service   = "test-service-#{Time.now.to_i}"
    @endpoint  = "test-endpoint-#{Time.now.to_i}"

    $VERBOSE = nil
  end

  after :each do
    namespace_path = ServiceDirectory::RegistrationService::Paths.namespace_path(
      project: @project,
      location: @location,
      namespace: @namespace
    )
    # Ignore errors from delete_namespace because some tests will clean the
    # namespace up, which would cause 'NOT_FOUND' errors
    begin
      delete_namespace(namespace_path: namespace_path)
    rescue
    end
  end

  it "can create namespace" do
    expect {
      $create_namespace.call(
        project:   @project,
        location:  @location,
        namespace: @namespace
      )
    }.to output(/#{@namespace}/).to_stdout

    test_namespace = get_namespace(
      project:   @project,
      location:  @location,
      namespace: @namespace
    )
    expect(test_namespace.name).to include @namespace
  end

  it "can delete namespace" do
    test_namespace = create_namespace(
      project:   @project,
      location:  @location,
      namespace: @namespace
    )

    expect {
      $delete_namespace.call(
        project:   @project,
        location:  @location,
        namespace: @namespace
      )
    }.to output(/#{@namespace}/).to_stdout
  end

  it "can create service" do
    test_namespace = create_namespace(
      project:   @project,
      location:  @location,
      namespace: @namespace
    )

    expect {
      $create_service.call(
        project:   @project,
        location:  @location,
        namespace: @namespace,
        service:   @service

      )
    }.to output(/#{@service}/).to_stdout

    test_service = get_service(
      project:   @project,
      location:  @location,
      namespace: @namespace,
      service:   @service

    )
    expect(test_service.name).to include @service
  end

  it "can delete service" do
    test_namespace = create_namespace(
      project:   @project,
      location:  @location,
      namespace: @namespace
    )
    test_service = create_service(
      project:   @project,
      location:  @location,
      namespace: @namespace,
      service:   @service
    )

    expect {
      $delete_service.call(
        project:   @project,
        location:  @location,
        namespace: @namespace,
        service:   @service
      )
    }.to output(/#{@service}/).to_stdout
  end

  it "can create endpoint" do
    test_namespace = create_namespace(
      project:   @project,
      location:  @location,
      namespace: @namespace
    )
    test_service = create_service(
      project:   @project,
      location:  @location,
      namespace: @namespace,
      service:   @service
    )

    expect {
      $create_endpoint.call(
        project:   @project,
        location:  @location,
        namespace: @namespace,
        service:   @service,
        endpoint:  @endpoint
      )
    }.to output(/#{@endpoint}/).to_stdout

    test_endpoint = get_endpoint(
      project:   @project,
      location:  @location,
      namespace: @namespace,
      service:   @service,
      endpoint:  @endpoint
    )
    expect(test_endpoint.name).to include @endpoint
  end

  it "can delete endpoint" do
    test_namespace = create_namespace(
      project:   @project,
      location:  @location,
      namespace: @namespace
    )
    test_service = create_service(
      project:   @project,
      location:  @location,
      namespace: @namespace,
      service:   @service
    )
    test_endpoint = create_endpoint(
      project:   @project,
      location:  @location,
      namespace: @namespace,
      service:   @service,
      endpoint:  @endpoint
    )
    expect {
      $delete_endpoint.call(
        project:   @project,
        location:  @location,
        namespace: @namespace,
        service:   @service,
        endpoint:  @endpoint
      )
    }.to output(/#{@endpoint}/).to_stdout
  end

  it "can resolve service" do
    test_namespace = create_namespace(
      project:   @project,
      location:  @location,
      namespace: @namespace
    )
    test_service = create_service(
      project:   @project,
      location:  @location,
      namespace: @namespace,
      service:   @service
    )
    test_endpoint = create_endpoint(
      project:   @project,
      location:  @location,
      namespace: @namespace,
      service:   @service,
      endpoint:  @endpoint
    )
    expect {
      $resolve_service.call(
        project:   @project,
        location:  @location,
        namespace: @namespace,
        service:   @service
      )
    }.to output(/#{@endpoint}/).to_stdout
  end

end
