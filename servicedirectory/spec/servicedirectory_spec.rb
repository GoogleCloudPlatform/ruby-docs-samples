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
require "google/cloud/service_directory"
require_relative "../servicedirectory"

describe "Service Directory API Test" do
  ServiceDirectory = Google::Cloud::ServiceDirectory::V1beta1

  def get_namespace project:, location:, namespace:
    client = Google::Cloud::ServiceDirectory.registration_service
    namespace_path = client.namespace_path(
      project:   project,
      location:  location,
      namespace: namespace
    )
    client.get_namespace name: namespace_path
  end

  def get_service project:, location:, namespace:, service:
    client = Google::Cloud::ServiceDirectory.registration_service
    service_path = client.service_path(
      project:   project,
      location:  location,
      namespace: namespace,
      service:   service
    )
    client.get_service name: service_path
  end

  def get_endpoint project:, location:, namespace:, service:, endpoint:
    client = Google::Cloud::ServiceDirectory.registration_service
    endpoint_path = client.endpoint_path(
      project:   project,
      location:  location,
      namespace: namespace,
      service:   service,
      endpoint:  endpoint
    )
    client.get_endpoint name: endpoint_path
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
    client = Google::Cloud::ServiceDirectory.registration_service
    namespace_path = client.namespace_path(
      project: @project,
      location: @location,
      namespace: @namespace
    )
    # Ignore errors from delete_namespace because some tests will clean the
    # namespace up, which would cause 'NOT_FOUND' errors
    begin
      client.delete_namespace name: namespace_path
    rescue
    end
  end

  it "can create namespace" do
    expect {
      create_namespace(
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
      delete_namespace(
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
      create_service(
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
      delete_service(
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
      create_endpoint(
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
      delete_endpoint(
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
      resolve_service(
        project:   @project,
        location:  @location,
        namespace: @namespace,
        service:   @service
      )
    }.to output(/#{@endpoint}/).to_stdout
  end

end
