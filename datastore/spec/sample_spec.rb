# Copyright 2016 Google, Inc
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

require_relative "../sample"
require "rspec"

describe "Datastore sample" do
  attr_reader :datastore

  before :all do
    @gcloud = Gcloud.new
    @datastore = @gcloud.datastore

    task_list = datastore.entity "TaskList", "default"
    datastore.save task_list

    task_key = datastore.key "Task", "sampleTask"
    task_key.parent = task_list.key
    create_task task_key

    create_task datastore.key("Task", "sampleTask1")
    create_task datastore.key("Task", "sampleTask2")
  end

  before :each do
    allow(Gcloud).to receive(:new).and_return(@gcloud)
  end

  after :all do
    delete_tasks
    delete_task_lists
    delete_accounts
  end

  def create_task task_key
    task = datastore.entity task_key do |t|
      t["type"] = "Personal"
      t["created"] = Time.utc(1999, 12, 31)
      t["done"] = false
      t["priority"] = 4
      t["percent_complete"] = 10.0
      t["description"] = "A task description."
      t["tag"] = ["fun", "programming"]
    end
    datastore.save task
  end

  def delete_tasks
    tasks = datastore.run datastore.query("Task")
    datastore.delete(*tasks.map(&:key)) unless tasks.empty?
  end

  def delete_task_lists
    datastore.delete(datastore.key("TaskList", "default"))
  end

  def delete_accounts
    accounts = datastore.run datastore.query("Account")
    datastore.delete(*accounts.map(&:key)) unless accounts.empty?
  end

  it "supports incomplete_key" do
    task_key = incomplete_key

    expect(task_key.kind).to eq("Task")
    expect(task_key.name).to be(nil)
  end

  it "supports named_key" do
    task_key = named_key

    expect(task_key.kind).to eq("Task")
    expect(task_key.name).to eq("sampleTask")
  end

  it "supports key_with_parent" do
    task_key = key_with_parent

    expect(task_key.kind).to eq("Task")
    expect(task_key.name).to eq("sampleTask")
    expect(task_key.path).to eq([["TaskList", "default"],
                                 ["Task", "sampleTask"]])
  end

  it "supports key_with_multilevel_parent" do
    task_key = key_with_multilevel_parent

    expect(task_key.kind).to eq("Task")
    expect(task_key.name).to eq("sampleTask")
    expect(task_key.path).to eq([["User", "alice"],
                                 ["TaskList", "default"],
                                 ["Task", "sampleTask"]])
  end

  it "supports entity_with_parent" do
    task = entity_with_parent

    expect(task.key.name).to eq("sampleTask")
    expect(task.key.path).to eq([["TaskList", "default"],
                                 ["Task", "sampleTask"]])
    expect(task.persisted?).to be(false)
    expect_basic_task task
  end

  it "supports properties" do
    time_now = Time.now
    allow(Time).to receive(:now).and_return(time_now)

    task = properties

    expect(task.persisted?).to be(false)
    expect(task.properties.to_h.size).to eq(6)
    expect_basic_task task
    expect(task["created"]).to eq(time_now)
    expect(task["priority"]).to eq(4)
    expect(task["percent_complete"]).to eq(10.0)
    expect(task["description"]).to eq("Learn Cloud Datastore")
  end

  it "supports array_value" do
    task = array_value

    expect(task.properties.to_h.size).to eq(2)
    expect(task["tags"]).to eq(["fun", "programming"])
    expect(task["collaborators"]).to eq(["alice", "bob"])
  end

  it "supports basic_entity" do
    task = basic_entity

    expect(task.persisted?).to be(false)
    expect_basic_task task
  end

  it "supports upsert" do
    task = upsert

    expect(task.key.id.nil?).to be(true)
    expect(task.key.name).to eq("sampleTask")
    expect(task.persisted?).to be(true)
    expect_basic_task task
  end

  it "supports insert" do
    task = insert

    expect(task.key.id.nil?).to be(false)
    expect(task.key.name.nil?).to be(true)
    expect(task.persisted?).to be(true)
    expect_basic_task task
  end

  it "supports lookup" do
    task = lookup

    expect(task.key.id.nil?).to be(true)
    expect(task.key.name).to eq("sampleTask")
    expect(task.persisted?).to be(true)
    expect_basic_task task
  end

  it "supports update" do
    task = update

    expect(task.persisted?).to be(true)
    expect(task.properties.to_h.size).to eq(4)
    expect(task["type"]).to eq("Personal")
    expect(task["done"]).to be(false)
    expect(task["priority"]).to eq(5)
    expect(task["description"]).to eq("Learn Cloud Datastore")
  end

  it "supports delete" do
    task_key = delete

    expect(task_key.name).to eq("sampleTask")
    task = datastore.find task_key
    expect(task.nil?).to be(true)
  end

  it "supports batch_upsert" do
    task_key1, task_key2 = batch_upsert

    expect(task_key1.id.nil?).to be(false)
    expect(task_key1.frozen?).to be(true)
    expect(task_key2.id.nil?).to be(false)
    expect(task_key2.frozen?).to be(true)
  end

  it "supports batch_lookup" do
    tasks = batch_lookup

    expect(tasks.size).to eq(2)
    expect_basic_task tasks.first
  end

  it "supports batch_delete" do
    task_key1, task_key2 = batch_delete

    expect(task_key1.name).to eq("sampleTask1")
    expect(task_key2.name).to eq("sampleTask2")
    tasks = datastore.find_all task_key1, task_key2
    expect(tasks.empty?).to be(true)
  end

  it "supports basic_query run_query" do
    tasks = basic_query

    expect(tasks.empty?).to be(false)
    tasks.each { |t| expect_basic_task t }
  end

  it "supports property_filter" do
    query = property_filter
    tasks = datastore.run query

    expect(tasks.empty?).to be(false)
    tasks.each { |t| expect_basic_task t }
  end

  it "supports composite_filter" do
    query = composite_filter
    tasks = datastore.run query

    expect(tasks.empty?).to be(false)
    tasks.each { |t| expect_basic_task t }
  end

  it "supports key_filter" do
    query = key_filter
    tasks = datastore.run query

    expect(tasks.empty?).to be(false)
    tasks.each { |t| expect_basic_task t }
  end

  it "supports ascending_sort" do
    query = ascending_sort
    tasks = datastore.run query

    expect(tasks.empty?).to be(false)
    tasks.each { |t| expect_basic_task t }
  end

  it "supports descending_sort" do
    query = descending_sort
    tasks = datastore.run query

    expect(tasks.empty?).to be(false)
    tasks.each { |t| expect_basic_task t }
  end

  it "supports multi_sort" do
    query = multi_sort
    tasks = datastore.run query

    expect(tasks.empty?).to be(false)
    tasks.each { |t| expect_basic_task t }
  end

  it "supports kindless_query" do
    query = kindless_query
    entities = datastore.run query

    expect(entities.empty?).to be(false)
  end

  it "supports ancestor_query" do
    query = ancestor_query
    tasks = datastore.run query

    expect(tasks.empty?).to be(false)
    expect(tasks.first.key.kind).to eq("Task")
    expect(tasks.first.key.parent.kind).to eq("TaskList")
  end

  it "supports projection_query run_query_projection" do
    priorities, percent_completes = projection_query

    expect(priorities.empty?).to be(false)
    expect(priorities.first).to eq(4)
    expect(percent_completes.empty?).to be(false)
    expect(percent_completes.first).to eq(10.0)
  end

  it "supports keys_only_query run_keys_only_query" do
    keys = keys_only_query

    expect(keys.empty?).to be(false)
    expect(keys.first.kind).to eq("Task")
  end

  it "supports distinct_query" do
    query = distinct_on_query
    tasks = datastore.run query

    expect(tasks.empty?).to be(false)
    expect(tasks.first.key.kind).to eq("Task")
    expect(tasks.first["type"]).to eq("Personal")
    expect(tasks.first["priority"]).to eq(4)
    expect(tasks.first.properties.to_h.size).to eq(2)
  end

  it "supports distinct_on_query" do
    query = distinct_on_query
    tasks = datastore.run query

    expect(tasks.empty?).to be(false)
    expect(tasks.first.key.kind).to eq("Task")
    expect(tasks.first["type"]).to eq("Personal")
    expect(tasks.first["priority"]).to eq(4)
    expect(tasks.first.properties.to_h.size).to eq(2)
  end

  it "supports array_value_inequality_range" do
    query = array_value_inequality_range
    tasks = datastore.run query

    expect(tasks.empty?).to be(true)
  end

  it "supports array_value_equality" do
    query = array_value_equality
    tasks = datastore.run query

    expect(tasks.empty?).to be(false)
    expect(tasks.first["tag"]).to eq(["fun", "programming"])
  end

  it "supports inequality_range" do
    query = inequality_range
    tasks = datastore.run query

    expect(tasks.empty?).to be(false)
    expect(tasks.size).to eq(1)
    expect(tasks.first["created"]).to eq(Time.utc(1999, 12, 31))
  end

  it "throws when inequality_invalid" do
    query = inequality_invalid

    expect { datastore.run(query) }.to raise_error(Gcloud::InvalidArgumentError)
  end

  it "supports equal_and_inequality_range" do
    query = equal_and_inequality_range
    tasks = datastore.run query

    expect(tasks.empty?).to be(false)
    expect(tasks.size).to eq(1)
    expect(tasks.first["done"]).to be(false)
    expect(tasks.first["priority"]).to eq(4)
    expect(tasks.first["created"]).to eq(Time.utc(1999, 12, 31))
  end

  it "supports inequality_sort" do
    query = inequality_sort
    tasks = datastore.run query

    expect(tasks.empty?).to be(false)
    tasks.each { |t| expect_basic_task t }
  end

  it "supports inequality_sort_invalid_not_same" do
    query = inequality_sort_invalid_not_same

    expect { datastore.run(query) }.to raise_error(Gcloud::InvalidArgumentError)
  end

  it "supports inequality_sort_invalid_not_first" do
    query = inequality_sort_invalid_not_first

    expect { datastore.run(query) }.to raise_error(Gcloud::InvalidArgumentError)
  end

  it "supports limit" do
    query = limit
    tasks = datastore.run query

    expect(tasks.empty?).to be(false)
    expect(tasks.size).to be <= 5
  end

  it "supports cursor_paging" do
    query = cursor_paging
    tasks = datastore.run query

    expect(tasks.empty?).to be(false)
    expect(tasks.cursor.nil?).to be(false)
    expect(tasks.size).to eq(2)
  end

  it "supports eventual_consistent_query" do
    tasks = eventual_consistent_query

    expect(tasks.empty?).to be(false)
    expect(tasks.first.key.kind).to eq("Task")
    expect(tasks.first.key.parent.kind).to eq("TaskList")
  end

  it "supports unindexed_property_query" do
    query = unindexed_property_query
    tasks = datastore.run query

    expect(tasks.empty?).to be(false)
    expect(tasks.first["description"]).to eq("A task description.")
  end

  it "supports exploding_properties" do
    time_now = Time.now
    allow(Time).to receive(:now).and_return(time_now)

    task = exploding_properties

    expect(task["tags"]).to eq(["fun", "programming", "learn"])
    expect(task["collaborators"]).to eq(["alice", "bob", "charlie"])
    expect(task["created"]).to eq(time_now)
  end

  it "supports transactional_update" do
    from_account = datastore.entity "Account" do |a|
      a["balance"] = 20.0
    end
    to_account = datastore.entity "Account" do |a|
      a["balance"] = 20.0
    end
    datastore.save from_account, to_account
    amount = 10.0

    success = transfer_funds from_account.key, to_account.key, amount

    expect(success).to be(true)
    from_account = datastore.find from_account.key
    to_account = datastore.find to_account.key
    expect(to_account["balance"]).to eq(30.0)
    expect(from_account["balance"]).to eq(10.0)
  end

  it "supports transactional_retry" do
    from_account = datastore.entity "Account" do |a|
      a["balance"] = 20.0
    end
    to_account = datastore.entity "Account" do |a|
      a["balance"] = 20.0
    end
    datastore.save from_account, to_account
    amount = 10.0

    success = transactional_retry from_account.key, to_account.key, amount

    expect(success).to be(true)
  end

  it "supports transactional_get_or_create" do
    task_key = datastore.key "Task", "sampleTask"

    task = transactional_get_or_create task_key

    expect(task.key.id.nil?).to be(true)
    expect(task.key.name).to eq("sampleTask")
    expect(task.persisted?).to be(true)
    expect_basic_task task
  end

  it "supports transactional_single_entity_group_read_only" do
    tasks_in_list = transactional_single_entity_group_read_only

    expect(tasks_in_list.empty?).to be(false)
    expect(tasks_in_list.first.key.kind).to eq("Task")
    expect(tasks_in_list.first.key.parent.kind).to eq("TaskList")
  end

  it "supports namespace_run_query" do
    namespaces = namespace_run_query

    expect(namespaces.empty?).to be(true)
  end

  it "supports kind_run_query" do
    kinds = kind_run_query

    expect(kinds.empty?).to be(false)
    expect(kinds.first).to eq("Account")
  end

  it "supports property_run_query" do
    properties_by_kind = property_run_query

    expect(properties_by_kind.empty?).to be(false)
    expect(properties_by_kind.first.first).to eq("Account")
    expect(properties_by_kind.first.last).to eq(["balance"])
  end

  it "supports property_by_kind_run_query" do
    representations = property_by_kind_run_query

    expect(representations.empty?).to be(false)
    expect(representations.first.first).to eq("created")
    expect(representations.first.last).to eq(["INT64"])
  end

  it "supports property_filtering_run_query" do
    properties_by_kind = property_filtering_run_query

    expect(properties_by_kind.empty?).to be(false)
    expect(properties_by_kind.first.first).to eq("Task")
    expect(properties_by_kind.first.last).to eq(["priority", "tag", "type"])
  end

  it "supports gql_run_query" do
    tasks = gql_run_query

    expect(tasks.empty?).to be(false)
    tasks.each { |t| expect_basic_task t }
  end

  it "supports gql_named_binding_query" do
    gql_query = gql_named_binding_query
    tasks = datastore.run gql_query

    expect(tasks.empty?).to be(false)
    tasks.each do |t|
      expect_basic_task t
      expect(t["priority"]).to eq(4)
    end
  end

  it "supports gql_positional_binding_query" do
    gql_query = gql_positional_binding_query
    tasks = datastore.run gql_query

    expect(tasks.empty?).to be(false)
    tasks.each do |t|
      expect_basic_task t
      expect(t["priority"]).to eq(4)
    end
  end

  it "supports gql_literal_query" do
    gql_query = gql_literal_query
    tasks = datastore.run gql_query

    expect(tasks.empty?).to be(false)
    tasks.each do |t|
      expect_basic_task t
      expect(t["priority"]).to eq(4)
    end
  end

  def expect_basic_task task
    expect(task.key.kind).to eq("Task")
    expect(task["type"]).to eq("Personal")
    expect(task["done"]).to be(false)
  end
end
