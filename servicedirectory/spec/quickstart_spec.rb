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

describe "Service Directory Registration Service Quickstart" do
  before :all do
    $VERBOSE = nil
  end

  it "lists namespaces in a project" do
    test_project = ENV["GOOGLE_CLOUD_PROJECT"]
    test_location = "us-central1"
    test_parent = "projects/#{test_project}/locations/#{test_location}"

    # Ensure that there is some test namespace in the project
    test_namespace_id = "test-namespace-#{test_project}"
    registration_service = Google::Cloud::ServiceDirectory.registration_service
    test_namespaces = registration_service.list_namespaces parent: test_parent

    created = test_namespaces.any? do |namespace|
      namespace.name.end_with? test_namespace_id
    end

    unless created
      test_namespace = registration_service.create_namespace(
        parent: test_parent, namespace_id: test_namespace_id)
      expect(test_namespace).not_to eq nil
      expect(test_namespace.name).to include test_namespace_id
    end

    expect {
      load File.expand_path("../quickstart.rb", __dir__)
    }.to output(
      /#{test_namespace_id}/
    ).to_stdout
  end
end
