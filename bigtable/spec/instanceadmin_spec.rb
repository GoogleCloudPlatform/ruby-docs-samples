require_relative "spec_helper"
require "securerandom"
require "google/cloud/bigtable"
require_relative "../instanceadmin"

describe "Google Cloud Bigtable instance admin samples" do
  it "create production instance, list instances, list clusters, add cluster, \
      delete cluster delete instance" do
    instance_id = "test-instance-#{SecureRandom.hex 8}"
    cluster_id = "test-cluster-#{SecureRandom.hex 8}"
    cluster_location = "us-central1-f"

    output = capture do
      create_prod_instance(
        @project_id,
        instance_id,
        cluster_id,
        cluster_location
      )
    end

    expect(output).to include "Creating a PRODUCTION Instance"
    expect(output).to include "Created Instance: #{instance_id}"
    expect(output).to include "Instance: #{instance_id}"
    expect(output).to include "Get Instance id: #{instance_id}"
    expect(output).to include "Cluster: #{cluster_id}"

    cluster_id1 = "test-cluster-#{SecureRandom.hex 8}"
    cluster_id1_locations = "us-central1-c"
    output = capture do
      add_cluster @project_id, instance_id, cluster_id1, cluster_id1_locations
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
    instance_id = "test-instance-#{SecureRandom.hex 8}"
    cluster_id = "test-cluster-#{SecureRandom.hex 8}"
    cluster_location = "us-central1-f"

    output = capture do
      create_dev_instance @project_id, instance_id, cluster_id, cluster_location
    end

    expect(output).to include "Creating a DEVELOPMENT Instance"
    expect(output).to include "Created development instance: #{instance_id}"

    instance = @bigtable.instance instance_id
    instance.delete
  end
end
