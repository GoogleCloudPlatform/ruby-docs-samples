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


def list_entities project_id:, entity_type_id:
  # [START dialogflow_list_entities]
  # project_id = "Your Google Cloud project ID"
  # entity_type_id = "some_entity_type_id"
  
  require "google/cloud/dialogflow"

  entity_types_client = Google::Cloud::Dialogflow::EntityTypes.new
  parent = entity_types_client.class.entity_type_path project_id, entity_type_id

  entities = entity_types_client.get_entity_type(parent).entities

  entities.each do |entity|
    puts "Entity value:    #{entity.value}"
    puts "Entity synonyms: #{entity.synonyms}"
  end
  # [END dialogflow_list_entities]
end


def create_entity project_id:, entity_type_id:, entity_value:, synonyms:
  # [START dialogflow_create_entity]
  # project_id = "Your Google Cloud project ID"
  # entity_type_id = "some_entity_type_id"
  # entity_value = "some_entity_value"
  # synonyms = ["synonym1", "synonym2"]
  
  require "google/cloud/dialogflow"

  entity_types_client = Google::Cloud::Dialogflow::EntityTypes.new
  entity_type_path = entity_types_client.class.entity_type_path project_id, entity_type_id

  entity = { value: entity_value, synonyms: synonyms }

  response = entity_types_client.batch_create_entities entity_type_path, [entity]

  puts "Entity created: #{response}"
  # [END dialogflow_create_entity]
end


def delete_entity project_id:, entity_type_id:, entity_value:
  # [START dialogflow_delete_entity]
  # project_id = "Your Google Cloud project ID"
  # entity_type_id = "some_entity_type_id"
  # entity_value = "some_entity_value"
  
  require "google/cloud/dialogflow"

  entity_types_client = Google::Cloud::Dialogflow::EntityTypes.new
  entity_type_path = entity_types_client.class.entity_type_path project_id, entity_type_id

  response = entity_types_client.batch_delete_entities entity_type_path, [entity_value]
  # [END dialogflow_delete_entity]
end


if __FILE__ == $PROGRAM_NAME
  project_id = ENV["GOOGLE_CLOUD_PROJECT"]
  case ARGV.shift
  when "list"
    entity_type_id = ARGV.shift
    list_entities project_id: project_id, entity_type_id: entity_type_id
  when "create"
    entity_type_id = ARGV.shift
    entity_value = ARGV.shift
    synonyms = ARGV
    create_entity project_id: project_id, entity_type_id: entity_type_id,
                  entity_value: entity_value, synonyms: synonyms
  when "delete"
    entity_type_id = ARGV.shift
    entity_value = ARGV.shift
    delete_entity project_id: project_id, entity_type_id: entity_type_id,
                  entity_value: entity_value
  else
    puts <<-usage
Usage: ruby entity_management.rb [commang] [arguments]

Commands:
  list    <entity_type_id>
  create  <entity_type_id> <entity_value> [<synonym1> [<synonym2> ...]]
  delete  <entity_type_id> <entity_value>

Environment variables:
  GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    usage
  end
end
