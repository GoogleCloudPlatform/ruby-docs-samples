require_relative "spec_helper"
require "securerandom"
require "google/cloud/bigtable"
require_relative "../instanceadmin"

describe "Google Cloud Bigtable instance admin samples" do
  before do
    @project_id = ENV["GOOGLE_CLOUD_BIGTABLE_PROJECT"]

    if @project_id.nil?
      skip "GOOGLE_CLOUD_BIGTABLE_TEST_INSTANCE and/or " \
        "GOOGLE_CLOUD_BIGTABLE_PROJECT not defined"
    end

    @bigtable = Google::Cloud::Bigtable.new project_id: @project_id
  end

  it "create production instance, list instances, list clusters, add cluster, \
      delete cluster delete instance" do
    instance_id = "test-instance-#{SecureRandom.hex(8)}"
    cluster_id = "test-cluster-#{SecureRandom.hex(8)}"

    output = capture do
      create_prod_instance @project_id, instance_id, cluster_id
    end

    expect(output).to include "Creating a PRODUCTION Instance"
    expect(output).to include "Created Instance: #{instance_id}"
    expect(output).to include "Instance: #{instance_id}"
    expect(output).to include "Get Instance id: #{instance_id}"
    expect(output).to include "Cluster: #{cluster_id}"

    cluster_id1 = "test-cluster-#{SecureRandom.hex(8)}"
    output = capture do
      add_cluster @project_id, instance_id, cluster_id1
    end

    expect(output).to include "Cluster created: #{cluster_id1}"

    output = capture do
      delete_cluster @project_id, instance_id, cluster_id1
    end

    expect(output).to include "Cluster deleted: #{cluster_id1}"

    output = capture do
      delete_instance @project_id, instance_id
    end

    expect(output).to include "Instance deleted: #{instance_id}"
  end

  it "create development instance" do
    instance_id = "test-instance-#{SecureRandom.hex(8)}"
    cluster_id = "test-cluster-#{SecureRandom.hex(8)}"

    output = capture do
      create_dev_instance @project_id, instance_id, cluster_id
    end

    expect(output).to include "Creating a DEVELOPMENT Instance"
    expect(output).to include "Created development instance: #{instance_id}"

    instance = @bigtable.instance instance_id
    instance.delete
  end
end
