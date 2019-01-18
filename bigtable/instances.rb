# frozen_string_literal: true

# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Import google bigtable client lib
require "google-cloud-bigtable"

def create_prod_instance instance_id, cluster_id
  bigtable = Google::Cloud.new.bigtable
  p "==> Check Instance Exists"

  # [START bigtable_check_instance_exists]
  if bigtable.instance(instance_id)
    p "Instance #{instance_id} exists"
  # [END bigtable_check_instance_exists]
  else
    # [START bigtable_create_prod_instance]
    p "==> Creating a PRODUCTION Instance"
    job = bigtable.create_instance(
      instance_id,
      display_name: "Sample production instance",
      labels: { "env": "production" },
      type: :PRODUCTION # Optional as default type is :PRODUCTION
    ) do |clusters|
      clusters.add(cluster_id, "us-central1-f", nodes: 3, storage_type: :SSD)
    end

    job.wait_until_done!
    instance = job.instance
    # [END bigtable_create_prod_instance]
    p "Created Instance: #{instance.instance_id}"
  end

  p "==> Listing Instances"
  # [START bigtable_list_instances]
  bigtable.instances.all do |i|
    p i.instance_id
  end
  # [END bigtable_list_instances]

  p "==> Get Instance"
  # [START bigtable_get_instance]
  p bigtable.instance(instance_id)
  # [END bigtable_get_instance]

  p "==> Listing Clusters of #{instance_id}" do
    # [START bigtable_get_clusters]
    bigtable.instance(instance_id).clusters.all do |cluster|
      p cluster.cluster_id
    end
    # [END bigtable_get_clusters]
  end
end

def create_dev_instance instance_id, cluster_id
  bigtable = Google::Cloud.new.bigtable
  p "==> Creating a DEVELOPMENT Instance"

  # [START bigtable_create_dev_instance]
  job = bigtable.create_instance(
    instance_id,
    display_name: "Sample development instance",
    labels: { "env": "development" },
    type: :DEVELOPMENT
  ) do |clusters|
    clusters.add(cluster_id, "us-central1-f", storage_type: :HDD)
  end

  job.wait_until_done!
  instance = job.instance
  # [END bigtable_create_dev_instance]
  p "==> Created development instance: #{instance.instance_id}"
end

def delete_instance instance_id
  bigtable = Google::Cloud.new.bigtable
  instance = bigtable.instance(instance_id)
  p "==> Deleting Instance"

  # [START bigtable_delete_instance]
  instance.delete
  # [END bigtable_delete_instance]
  p "==> Instance deleted: #{instance.instance_id}\n"
end

def add_cluster instance_id, cluster_id
  bigtable = Google::Cloud.new.bigtable
  instance = bigtable.instance(instance_id)

  unless instance
    p "==> Instance does not exists"
    return
  end

  p "==> Adding Cluster to Instance #{instance.instance_id}"

  # [START bigtable_create_cluster]
  job = instance.create_cluster(
    cluster_id,
    "us-central1-c",
    nodes: 3,
    storage_type: :SSD
  )

  job.wait_until_done!
  cluster = job.cluster
  # [END bigtable_create_cluster]
  p "==> Cluster created: #{cluster.cluster_id}\n"
end

def delete_cluster instance_id, cluster_id
  bigtable = Google::Cloud.new.bigtable
  instance = bigtable.instance(instance_id)
  cluster = instance.cluster(cluster_id)
  p "==> Deleting Cluster"

  # [START bigtable_delete_cluster]
  cluster.delete
  # [END bigtable_delete_cluster]

  p "Cluster deleted: #{cluster.cluster_id}"
end

if __FILE__ == $PROGRAM_NAME
  case ARGV.shift
  when "run"
    create_prod_instance ARGV.shift, ARGV.shift
  when "add-cluster"
    add_cluster ARGV.shift, ARGV.shift
  when "del-cluster"
    delete_cluster ARGV.shift, ARGV.shift
  when "del-instance"
    delete_instance ARGV.shift
  when "dev-instance"
    create_dev_instance ARGV.shift, ARGV.shift
  else
    puts <<~USAGE
       Usage: bundle exec ruby instances.rb [command] [arguments]

       Commands:
       run          <instance_id> <cluster_id>   Creates an Instance(type: PRODUCTION) and run basic instance-operations
       add-cluster  <instance_id> <cluster_id>   Add Cluster
       del-cluster  <instance_id> <cluster_id>   Delete the Cluster
       del-instance <instance_id>                Delete the Instance
       dev-instance <instance_id> <cluster_id>   Create Development Instance
     USAGE
   end
end
