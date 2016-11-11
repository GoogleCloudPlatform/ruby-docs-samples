# Copyright 2016 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in write, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START build_service]
require "google/cloud"

def create_client project_id:
  gcloud = Google::Cloud.new project_id
  gcloud.datastore
end
# [END build_service]

# [START add_entity]
def new_task project_id:, description:
  datastore = create_client project_id: project_id

  task = datastore.entity "Task" do |t|
    t["description"] = description
    t["created"] = Time.now
    t["done"] = false
    t.exclude_from_indexes! "description", true
  end
  datastore.save task

  puts task.key.id
  task.key.id
end
# [END add_entity]

# [START update_entity]
def mark_done project_id:, task_id:
  datastore = create_client project_id: project_id

  task = datastore.find "Task", task_id.to_i
  task["done"] = true
  datastore.save task
end
# [END update_entity]

# [START retrieve_entities]
def list_tasks project_id:
  datastore = create_client project_id: project_id

  query = datastore.query("Task").
            order("created")
  tasks = datastore.run query

  tasks.each do |t|
    puts t['description']
    puts t['done'] ? "  Done" : "  Not Done"
    puts "  ID: #{t.key.id}"
  end
end
# [END retrieve_entities]

# [START delete_entity]
def delete_task project_id:, task_id:
  datastore = create_client project_id: project_id

  task = datastore.find "Task", task_id.to_i
  datastore.delete task
end
# [END delete_entity]

if __FILE__ == $0
  project_id = ENV["GOOGLE_CLOUD_PROJECT"]
  case ARGV.shift
  when "new"
    new_task project_id: project_id,
             description: ARGV.shift
  when "done"
    mark_done project_id:  project_id,
              task_id: ARGV.shift
  when "list"
    list_tasks project_id:  project_id
  when "delete"
    delete_task project_id:  project_id,
                task_id: ARGV.shift
  else
    puts <<-usage
Usage: bundle exec ruby tasks.rb [command] [arguments]

Commands:
  new <description>    Adds a task with description <description>.
  done <task_id>       Marks a task as done.
  list                 Lists all tasks by creation time.
  delete <task_id>     Deletes a task.

Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    usage
  end
end
