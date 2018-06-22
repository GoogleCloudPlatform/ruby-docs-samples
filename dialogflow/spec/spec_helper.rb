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


require "google/cloud/dialogflow"


def get_entity_type_ids project_id:, display_name:
  entity_types_client = Google::Cloud::Dialogflow::EntityTypes.new
  parent = entity_types_client.class.project_agent_path project_id

  entity_types = entity_types_client.list_entity_types parent

  selected_entity_types = entity_types.select { |entity_type| entity_type.display_name == display_name }

  entity_type_ids = selected_entity_types.map { |entity_type| entity_type.name.split("/").last }

  entity_type_ids
end


def get_intent_ids project_id:, display_name:
  intents_client = Google::Cloud::Dialogflow::Intents.new
  parent = intents_client.class.project_agent_path project_id

  intents = intents_client.list_intents parent

  selected_intents = intents.select { |intent| intent.display_name == display_name }

  intent_ids = selected_intents.map { |intent| intent.name.split("/").last }

  intent_ids
end

# Capture and return STDOUT output by block
def hide &block
  real_stdout = $stdout
  $stdout = StringIO.new
  block.call
ensure
  $stdout = real_stdout
end

