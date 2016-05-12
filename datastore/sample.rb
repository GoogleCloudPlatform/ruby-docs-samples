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

require "gcloud"

def incomplete_key
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START incomplete_key]
  task_key = datastore.key "Task"
  # [END incomplete_key]
end

def named_key
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START named_key]
  task_key = datastore.key "Task", "sampleTask"
  # [END named_key]
end

def key_with_parent
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START key_with_parent]
  task_key = datastore.key [["TaskList", "default"], ["Task", "sampleTask"]]
  # [END key_with_parent]

  task_key
end

def key_with_multilevel_parent
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START key_with_multilevel_parent]
  task_key = datastore.key([
                             ["User", "alice"],
                             ["TaskList", "default"],
                             ["Task", "sampleTask"]
                           ])
  # [END key_with_multilevel_parent]

  task_key
end

def entity_with_parent
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START entity_with_parent]
  task_key = datastore.key [["TaskList", "default"], ["Task", "sampleTask"]]

  task = datastore.entity task_key do |t|
    t["type"] = "Personal"
    t["done"] = false
    t["priority"] = 4
    t["description"] = "Learn Cloud Datastore"
  end
  # [END entity_with_parent]

  task
end

def properties
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START properties]
  task = datastore.entity "Task" do |t|
    t["type"] = "Personal"
    t["created"] = Time.now
    t["done"] = false
    t["priority"] = 4
    t["percent_complete"] = 10.0
    t["description"] = "Learn Cloud Datastore"
  end
  # [END properties]
end

def array_value
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START array_value]
  task = datastore.entity "Task", "sampleTask" do |t|
    t["tags"] = ["fun", "programming"]
    t["collaborators"] = ["alice", "bob"]
  end
  # [END array_value]
end

def basic_entity
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START basic_entity]
  task = datastore.entity "Task" do |t|
    t["type"] = "Personal"
    t["done"] = false
    t["priority"] = 4
    t["description"] = "Learn Cloud Datastore"
  end
  # [END basic_entity]

  task
end

def upsert
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START upsert]
  task = datastore.entity "Task", "sampleTask" do |t|
    t["type"] = "Personal"
    t["done"] = false
    t["priority"] = 4
    t["description"] = "Learn Cloud Datastore"
  end
  datastore.save task
  # [END upsert]

  task
end

def insert
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START insert]
  task = datastore.entity "Task" do |t|
    t["type"] = "Personal"
    t["done"] = false
    t["priority"] = 4
    t["description"] = "Learn Cloud Datastore"
  end
  datastore.save task
  # [END insert]

  task
end

def lookup
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START lookup]
  task_key = datastore.key "Task", "sampleTask"
  task = datastore.find task_key
  # [END lookup]

  task
end

def update
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  task = datastore.entity "Task", "sampleTask" do |t|
    t["type"] = "Personal"
    t["done"] = false
    t["priority"] = 4
    t["description"] = "Learn Cloud Datastore"
  end
  datastore.save task

  # [START update]
  task = datastore.find "Task", "sampleTask"
  task["priority"] = 5
  datastore.save task
  # [END update]

  task
end

def delete
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START delete]
  task_key = datastore.key "Task", "sampleTask"
  datastore.delete task_key
  # [END delete]

  task_key
end

def batch_upsert
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START batch_upsert]
  task1 = datastore.entity "Task" do |t|
    t["type"] = "Personal"
    t["done"] = false
    t["priority"] = 4
    t["description"] = "Learn Cloud Datastore"
  end

  task2 = datastore.entity "Task" do |t|
    t["type"] = "Personal"
    t["done"] = false
    t["priority"] = 5
    t["description"] = "Integrate Cloud Datastore"
  end

  tasks = datastore.save(task1, task2)
  task_key1 = tasks[0].key
  task_key2 = tasks[1].key
  # [END batch_upsert]

  [task_key1, task_key2]
end

def batch_lookup
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START batch_lookup]
  task_key1 = datastore.key "Task", "sampleTask1"
  task_key2 = datastore.key "Task", "sampleTask2"
  tasks = datastore.find_all task_key1, task_key2
  # [END batch_lookup]
end

def batch_delete
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START batch_delete]
  task_key1 = datastore.key "Task", "sampleTask1"
  task_key2 = datastore.key "Task", "sampleTask2"
  datastore.delete task_key1, task_key2
  # [END batch_delete]

  [task_key1, task_key2]
end

def basic_query
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START basic_query]
  query = datastore.query("Task").
          where("done", "=", false).
          where("priority", ">=", 4).
          order("priority", :desc)
  # [END basic_query]

  # [START run_query]
  tasks = datastore.run query
  # [END run_query]
end

def property_filter
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START property_filter]
  query = datastore.query("Task").
          where("done", "=", false)
  # [END property_filter]
end

def composite_filter
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START composite_filter]
  query = datastore.query("Task").
          where("done", "=", false).
          where("priority", "=", 4)
  # [END composite_filter]
end

def key_filter
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START key_filter]
  query = datastore.query("Task").
          where("__key__", ">", datastore.key("Task", "someTask"))
  # [END key_filter]
end

def ascending_sort
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START ascending_sort]
  query = datastore.query("Task").
          order("created", :asc)
  # [END ascending_sort]
end

def descending_sort
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START descending_sort]
  query = datastore.query("Task").
          order("created", :desc)
  # [END descending_sort]
end

def multi_sort
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START multi_sort]
  query = datastore.query("Task").
          order("priority", :desc).
          order("created", :asc)
  # [END multi_sort]
end

def kindless_query
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  last_seen_key = datastore.key "Task", "a"
  # [START kindless_query]
  query = Gcloud::Datastore::Query.new
  query.where("__key__", ">", last_seen_key)
  # [END kindless_query]

  query
end

def ancestor_query
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START ancestor_query]
  ancestor_key = datastore.key "TaskList", "default"

  query = datastore.query("Task").
          ancestor(ancestor_key)
  # [END ancestor_query]
end

def projection_query
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START projection_query]
  query = datastore.query("Task").
          select("priority", "percent_complete")
  # [END projection_query]

  # [START run_query_projection]
  priorities = []
  percent_completes = []
  datastore.run(query).each do |task|
    priorities << task["priority"]
    percent_completes << task["percent_complete"]
  end
  # [END run_query_projection]

  [priorities, percent_completes]
end

def keys_only_query
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START keys_only_query]
  query = datastore.query("Task").
          select("__key__")
  # [END keys_only_query]

  # [START run_keys_only_query]
  keys = datastore.run(query).map(&:key)
  # [END run_keys_only_query]
end

def distinct_query
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START distinct_query]
  query = datastore.query("Task").
          select("type", "priority").
          distinct_on("type", "priority").
          order("type").
          order("priority")
  # [END distinct_query]
end

def distinct_on_query
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START distinct_on_query]
  query = datastore.query("Task").
          select("type", "priority").
          distinct_on("type").
          order("type").
          order("priority")
  # [END distinct_on_query]
end

def array_value_inequality_range
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START array_value_inequality_range]
  query = datastore.query("Task").
          where("tag", ">", "learn").
          where("tag", "<", "math")
  # [END array_value_inequality_range]
end

def array_value_equality
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START array_value_equality]
  query = datastore.query("Task").
          where("tag", "=", "fun").
          where("tag", "=", "programming")
  # [END array_value_equality]
end

def inequality_range
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START inequality_range]
  query = datastore.query("Task").
          where("created", ">=", Time.utc(1990, 1, 1)).
          where("created", "<", Time.utc(2000, 1, 1))
  # [END inequality_range]
end

def inequality_invalid
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START inequality_invalid]
  query = datastore.query("Task").
          where("created", ">=", Time.utc(1990, 1, 1)).
          where("priority", ">", 3)
  # [END inequality_invalid]
end

def equal_and_inequality_range
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START equal_and_inequality_range]
  query = datastore.query("Task").
          where("done", "=", false).
          where("priority", "=", 4).
          where("created", ">=", Time.utc(1990, 1, 1)).
          where("created", "<", Time.utc(2000, 1, 1))
  # [END equal_and_inequality_range]
end

def inequality_sort
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START inequality_sort]
  query = datastore.query("Task").
          where("priority", ">", 3).
          order("priority").
          order("created")
  # [END inequality_sort]
end

def inequality_sort_invalid_not_same
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START inequality_sort_invalid_not_same]
  query = datastore.query("Task").
          where("priority", ">", 3).
          order("created")
  # [END inequality_sort_invalid_not_same]
end

def inequality_sort_invalid_not_first
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START inequality_sort_invalid_not_first]
  query = datastore.query("Task").
          where("priority", ">", 3).
          order("created").
          order("priority")
  # [END inequality_sort_invalid_not_first]
end

def limit
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START limit]
  query = datastore.query("Task").
          limit(5)
  # [END limit]
end

def cursor_paging
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  page_size = 2
  query = datastore.query("Task").
          limit(page_size)
  tasks = datastore.run query

  page_cursor = tasks.cursor

  # [START cursor_paging]
  query = datastore.query("Task").
          limit(page_size).
          start(page_cursor)
  # [END cursor_paging]
end

def eventual_consistent_query
  # [START eventual_consistent_query]
  ancestor_key = datastore.key "TaskList", "default"

  query = datastore.query("Task").
          ancestor(ancestor_key)

  tasks = datastore.run query, consistency: :eventual
  # [END eventual_consistent_query]

  tasks
end

def unindexed_property_query
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START unindexed_property_query]
  query = datastore.query("Task").
          where("description", "=", "A task description.")
  # [END unindexed_property_query]
end

def exploding_properties
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START exploding_properties]
  task = datastore.entity "Task" do |t|
    t["tags"] = ["fun", "programming", "learn"]
    t["collaborators"] = ["alice", "bob", "charlie"]
    t["created"] = Time.now
  end
  # [END exploding_properties]
end

# [START transactional_update]
def transfer_funds from_key, to_key, amount
  datastore.transaction do |tx|
    from = tx.find from_key
    from["balance"] -= amount
    to = tx.find to_key
    to["balance"] += amount
    tx.save from, to
  end
end
# [END transactional_update]

def transactional_retry from_key, to_key, amount
  # [START transactional_retry]
  (1..5).each do |i|
    begin
      return transfer_funds from_key, to_key, amount
    rescue Gcloud::Error => e
      raise e if i == 5
    end
  end
  # [END transactional_retry]
end

def transactional_get_or_create task_key
  # [START transactional_get_or_create]
  task = nil
  datastore.transaction do |tx|
    task = tx.find task_key
    if task.nil?
      task = datastore.entity task_key do |t|
        t["type"] = "Personal"
        t["done"] = false
        t["priority"] = 4
        t["description"] = "Learn Cloud Datastore"
      end
      tx.save task
    end
  end
  # [END transactional_get_or_create]
  task
end

def transactional_single_entity_group_read_only
  tasks_in_list = nil
  # [START transactional_single_entity_group_read_only]
  task_list_key = datastore.key "TaskList", "default"
  datastore.transaction do |tx|
    task_list = tx.find task_list_key
    query = tx.query("Task").ancestor(task_list)
    tasks_in_list = tx.run query
  end
  # [END transactional_single_entity_group_read_only]
  tasks_in_list
end

def namespace_run_query
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START namespace_run_query]
  query = datastore.query("__namespace__").
          select("__key__").
          where("__key__", ">=", datastore.key("__namespace__", "g")).
          where("__key__", "<", datastore.key("__namespace__", "h"))

  namespaces = datastore.run(query).map do |entity|
    entity.key.name
  end
  # [END namespace_run_query]
end

def kind_run_query
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START kind_run_query]
  query = datastore.query("__kind__").
          select("__key__")

  kinds = datastore.run(query).map do |entity|
    entity.key.name
  end
  # [END kind_run_query]
end

def property_run_query
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START property_run_query]
  query = datastore.query("__property__").
          select("__key__")

  entities = datastore.run(query)
  properties_by_kind = entities.each_with_object({}) do |entity, memo|
    kind = entity.key.parent.name
    prop = entity.key.name
    memo[kind] ||= []
    memo[kind] << prop
  end
  # [END property_run_query]
end

def property_by_kind_run_query
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START property_by_kind_run_query]
  ancestor_key = datastore.key "__kind__", "Task"
  query = datastore.query("__property__").
          ancestor(ancestor_key)

  entities = datastore.run(query)
  representations = entities.each_with_object({}) do |entity, memo|
    property_name = entity.key.name
    property_types = entity["property_representation"]
    memo[property_name] = property_types
  end
  # [END property_by_kind_run_query]
end

def property_filtering_run_query
  gcloud = Gcloud.new
  datastore = gcloud.datastore

  # [START property_filtering_run_query]
  start_key = datastore.key [["__kind__", "Task"], ["__property__", "priority"]]
  query = datastore.query("__property__").
          select("__key__").
          where("__key__", ">=", start_key)

  entities = datastore.run(query)
  properties_by_kind = entities.each_with_object({}) do |entity, memo|
    kind = entity.key.parent.name
    prop = entity.key.name
    memo[kind] ||= []
    memo[kind] << prop
  end
  # [END property_filtering_run_query]
end

def gql_run_query
  # [START gql_run_query]
  gql_query = Gcloud::Datastore::GqlQuery.new
  gql_query.query_string = "SELECT * FROM Task ORDER BY created ASC"
  tasks = datastore.run gql_query
  # [END gql_run_query]
end

def gql_named_binding_query
  # [START gql_named_binding_query]
  gql_query = Gcloud::Datastore::GqlQuery.new
  gql_query.query_string = "SELECT * FROM Task " \
                           "WHERE done = @done AND priority = @priority"
  gql_query.named_bindings = { done: false, priority: 4 }
  # [END gql_named_binding_query]

  gql_query
end

def gql_positional_binding_query
  # [START gql_positional_binding_query]
  gql_query = Gcloud::Datastore::GqlQuery.new
  gql_query.query_string = "SELECT * FROM Task " \
                           "WHERE done = @1 AND priority = @2"
  gql_query.positional_bindings = [false, 4]
  # [END gql_positional_binding_query]

  gql_query
end

def gql_literal_query
  # [START gql_literal_query]
  gql_query = Gcloud::Datastore::GqlQuery.new
  gql_query.query_string = "SELECT * FROM Task " \
                           "WHERE done = false AND priority = 4"
  gql_query.allow_literals = true
  # [END gql_literal_query]

  gql_query
end
