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

# This application demonstrates how to perform basic operations on topics with
# the Google Cloud Pub/Sub API.
#
# For more information, see the README.md under /pubsub and the documentation at
# https://cloud.google.com/pubsub/docs.

require "google/cloud"

# [START pubsub_list_topics]
def list_topics
  # Instantiates the client library
  gcloud = Google::Cloud.new
  pubsub_client = gcloud.pubsub

  # Lists all topics in the current project
  topics = pubsub_client.topics

  puts "Topics:"
  topics.each do |topic|
    puts topic.name
  end
end
# [END pubsub_list_topics]

# [START pubsub_create_topic]
def create_topic topic_name:
  # Instantiates the client library
  gcloud = Google::Cloud.new
  pubsub_client = gcloud.pubsub

  # Creates a new topic, e.g. "my-new-topic"
  topic = pubsub_client.create_topic topic_name

  puts "Topic #{topic.name} created."
end
# [END pubsub_create_topic]

# [START pubsub_delete_topic]
def delete_topic topic_name:
  # Instantiates the client library
  gcloud = Google::Cloud.new
  pubsub_client = gcloud.pubsub

  # References an existing topic, e.g. "my-topic"
  topic = pubsub_client.topic topic_name, skip_lookup: true

  # Deletes the topic
  topic.delete

  puts "Topic #{topic.name} deleted."
end
# [END pubsub_delete_topic]

# [START pubsub_publish_messages]
def publish_message topic_name:, data:
  # Instantiates the client library
  gcloud = Google::Cloud.new
  pubsub_client = gcloud.pubsub

  # References an existing topic, e.g. "my-topic"
  topic  = pubsub_client.topic topic_name

  # Data must be a bytestring
  data = data.encode("iso-8859-1").encode("utf-8")

  # Publishes the message
  message = topic.publish data

  puts "Message #{message.message_id} published."
end
# [END pubsub_publish_messages]

# [START pubsub_get_topic_policy]
def get_topic_policy topic_name:
  # Instantiates the client library
  gcloud = Google::Cloud.new
  pubsub_client = gcloud.pubsub

  # References an existing topic, e.g. "my-topic"
  topic  = pubsub_client.topic topic_name

  # Retrieves the IAM policy for the topic
  policy = topic.policy

  puts "Policy for topic: #{policy.roles}."
end
# [END pubsub_get_topic_policy]

# [START pubsub_set_topic_policy]
def set_topic_policy topic_name:
  # Instantiates the client library
  gcloud = Google::Cloud.new
  pubsub_client = gcloud.pubsub

  # References an existing topic, e.g. "my-topic"
  topic  = pubsub_client.topic topic_name

  # Updates the IAM policy for the topic
  policy = topic.policy do |p|
    # Add a group as editors
    p.add "roles/pubsub.editor", "group:cloud-logs@google.com"
    # Add all users as viewers
    p.add "roles/pubsub.viewer", "allUsers"
  end

  puts "Updated policy for topic: #{policy.roles}."
end
# [END pubsub_set_topic_policy]

# [START pubsub_test_topic_permissions]
def test_topic_permissions topic_name:
  # Instantiates the client library
  gcloud = Google::Cloud.new
  pubsub_client = gcloud.pubsub

  # References an existing topic, e.g. "my-topic"
  topic  = pubsub_client.topic topic_name

  # Tests the IAM policy for the specified topic
  permissions = topic.test_permissions "pubsub.topics.attachSubscription",
                                       "pubsub.topics.publish",
                                       "pubsub.topics.update"

  puts "Tested permissions for topic: #{permissions}"
end
# [END pubsub_test_topic_permissions]

if __FILE__ == $PROGRAM_NAME
  command = ARGV.shift

  case command
  when "list"
    list_topics
  when "create"
    create_topic topic_name: ARGV.shift
  when "delete"
    delete_topic topic_name: ARGV.shift
  when "publish"
    publish_message topic_name: ARGV.shift, data: ARGV.shift
  when "get-policy"
    get_topic_policy topic_name: ARGV.shift
  when "set-policy"
    set_topic_policy topic_name: ARGV.shift
  when "test-permissions"
    test_topic_permissions topic_name: ARGV.shift
  else
    puts <<-usage
Usage: ruby topics.rb <command> [arguments]

Commands:
  list                                 Lists all topics in the current project.
  create <topic_name>                  Creates a new topic.
  delete <topic_name>                  Deletes a topic.
  publish <topic_name> <data>          Publishes a message.
  get-policy <topic_name>              Gets the IAM policy for a topic.
  set-policy <topic_name>              Sets the IAM policy for a topic.
  test-permissions <topic_name>        Tests the permissions for a topic.
  usage
  end
end