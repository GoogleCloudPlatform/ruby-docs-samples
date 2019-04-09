# Copyright 2018 Google, LLC
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
require "google/cloud/bigtable"

RSpec.configure do |config|
  config.before :all do
    @project_id = ENV["GOOGLE_CLOUD_BIGTABLE_PROJECT"] ||
                  ENV["GOOGLE_CLOUD_PROJECT"]

    skip "GOOGLE_CLOUD_BIGTABLE_PROJECT or GOOGLE_CLOUD_PROJECT not defined" if @project_id.nil?

    @bigtable = Google::Cloud::Bigtable.new project_id: @project_id

    @instance_id = ENV["GOOGLE_CLOUD_BIGTABLE_TEST_INSTANCE"] ||
                   "ruby-samples-test"
    @cluser_id = "ruby-cluster-test"
    @cluster_location = ENV["GOOGLE_CLOUD_BIGTABLE_TEST_ZONE"] || "us-east1-b"

    @instance = create_test_instance(
      @bigtable,
      @instance_id,
      @cluser_id,
      @cluster_location
    )
  end

  config.after :all do
    @instance&.delete
  end

  # Capture and return STDOUT output by block
  def capture
    real_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = real_stdout
  end
end

def create_test_instance bigtable, instance_id, cluster_id, cluster_location
  instance = bigtable.instance instance_id

  if instance.nil?
    p "Creating instance #{instance_id} in zone #{cluster_location}."

    job = bigtable.create_instance(
      instance_id,
      display_name: "Ruby Bigtable Example Tests",
      labels:       { env: "test" }
    ) do |clusters|
      clusters.add cluster_id, cluster_location, nodes: 3
    end

    job.wait_until_done!

    raise GRPC::BadStatus.new(job.error.code, job.error.message) if job.error?

    instance = job.instance
  end

  loop do
    # Wait until instance ready
    if instance.ready?
      p "#{instance.instance_id} instance is ready."
      break
    else
      sleep 5
      instance.reload!
    end
  end

  instance
end
