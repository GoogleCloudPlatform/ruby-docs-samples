# Copyright 2018 Google, Inc
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


require "securerandom"

def list_session_entity_types project_id:, session_id:
  # [START dialogflow_list_session_entity_types]
  # project_id = "Your Google Cloud project ID"
  # session_id = "Existing Session ID"

  require "google/cloud/dialogflow"

  session_entity_types_client = Google::Cloud::Dialogflow::SessionEntityTypes.new
  session_path = session_entity_types_client.class.session_path project_id, session_id

  session_entity_types = session_entity_types_client.list_session_entity_types session_path

  puts "SessionEntityTypes for session #{session_path}:\n"
  session_entity_types.each do |session_entity_type|
    entity_values = session_entity_type.entities.map(&:value)
    puts "SessionEntityType name:          #{session_entity_type.name}"
    puts "Number of entities:              #{session_entity_type.entities.size}"
    puts "SessionEntityType entity values: #{entity_values}\n"
  end
  # [END dialogflow_list_session_entity_types]
end

def create_session_entity_type(project_id:, session_id:,
                               entity_type_display_name:,
                               entity_values:)
  # [START dialogflow_create_session_entity_type]
  # project_id = "Your Google Cloud project ID"
  # session_id = "Existing Session ID"
  # entity_type_display_name = "Existing Entity Type Display Name"
  # entity_values = ["entity1", "entity2"]

  require "google/cloud/dialogflow"

  session_entity_types_client = Google::Cloud::Dialogflow::SessionEntityTypes.new
  session_path = session_entity_types_client.class.session_path project_id, session_id
  session_entity_type_name = session_entity_types_client.class.session_entity_type_path project_id, session_id, entity_type_display_name

  # Here we use the entity value as the only synonym.
  entities = entity_values.map { |entity_value| { value: entity_value, synonyms: [entity_value] } }

  session_entity_type = {
    name:                 session_entity_type_name,
    entities:             entities,
    # the modes are either ENTITY_OVERRIDE_MODE_OVERRIDE or ENTITY_OVERRIDE_MODE_SUPPLEMENT
    entity_override_mode: :ENTITY_OVERRIDE_MODE_OVERRIDE
  }

  response = session_entity_types_client.create_session_entity_type session_path, session_entity_type

  puts "SessionEntityType name: #{response.name}"
  # [END dialogflow_create_session_entity_type]
end

def delete_session_entity_type(project_id:, session_id:,
                               entity_type_display_name:)
  # [START dialogflow_delete_session_entity_type]
  # project_id = "Your Google Cloud project ID"
  # session_id = "Existing Session ID"
  # entity_type_display_name = "Existing Entity Type Display Name"

  require "google/cloud/dialogflow"

  session_entity_types_client = Google::Cloud::Dialogflow::SessionEntityTypes.new
  session_entity_type_name = session_entity_types_client.class.session_entity_type_path project_id, session_id, entity_type_display_name

  session_entity_types_client.delete_session_entity_type session_entity_type_name

  puts "Deleted Session Entity type: #{session_entity_type_name}"
  # [END dialogflow_delete_session_entity_type]
end


if $PROGRAM_NAME == __FILE__
  project_id = ENV["GOOGLE_CLOUD_PROJECT"]
  case ARGV.shift
  when "list"
    list_session_entity_types project_id: project_id,
                              session_id: ARGV.shift
  when "create"
    create_session_entity_type project_id:               project_id,
                               session_id:               ARGV.shift,
                               entity_type_display_name: ARGV.shift,
                               entity_values:            ARGV
  when "delete"
    delete_session_entity_type project_id:               project_id,
                               session_id:               ARGV.shift,
                               entity_type_display_name: ARGV.shift
  else
    puts <<~USAGE
      Usage: ruby session_entity_type_management.rb [commang] [arguments]

      Commands:
        list
          List all session entity types
        create  <session_id> <entity_type_display_name> [entity_value1, [entity_value2, ...]]
          Create a session entity type
        delete  <sessino_id> <session_entity_type_id>
          Delete a session entity type

      Environment variables:
        GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    USAGE
  end
end
