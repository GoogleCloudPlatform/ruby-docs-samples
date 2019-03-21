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

# [START datastore_quickstart]
# Imports the Google Cloud client library
require "google/cloud/datastore"

# Your Google Cloud Platform project ID
project_id = "YOUR_PROJECT_ID"

# Instantiates a client
datastore = Google::Cloud::Datastore.new project: project_id

# The kind for the new entity
kind = "Task"
# The name/ID for the new entity
name = "sampletask1"
# The Cloud Datastore key for the new entity
task_key = datastore.key kind, name

# Prepares the new entity
task = datastore.entity task_key do |t|
  t["description"] = "Buy milk"
end

# Saves the entity
datastore.save task

puts "Saved #{task.key.name}: #{task['description']}"
# [END datastore_quickstart]
