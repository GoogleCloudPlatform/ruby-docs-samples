# Copyright 2015 Google, Inc
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

gcloud = Gcloud.new "my-gcp-project-id"
pubsub = gcloud.pubsub

# [START create_topic]
def create_topic
  gcloud = Gcloud.new "my-gcp-project-id"
  pubsub = gcloud.pubsub

  topic = pubsub.create_topic "my-topic"

  puts "Topic created #{topic.name}"
end
# [END create_topic]

# [START create_subscription]
def create_subscription
  gcloud = Gcloud.new "my-gcp-project-id"
  pubsub = gcloud.pubsub
  topic = pubsub.topic "my-topic"

  subscription = topic.subscribe "my-subscription"

  puts "Subscription created #{subscription.name}"
end
# [END create_subscription]

# [START create_push_subscription]
def create_push_subscription
  gcloud = Gcloud.new "my-gcp-project-id"
  pubsub = gcloud.pubsub
  topic = pubsub.topic "my-topic"

  subscription = topic.subscribe(
    "my-subscription-push",
    endpoint: "https://my-gcp-project-id.appspot.com/push"
  )

  puts "Push subscription created #{subscription.name}"
end
# [END create_push_subscription]

# [START publish_message]
def publish_message
  gcloud = Gcloud.new "my-gcp-project-id"
  pubsub = gcloud.pubsub
  topic  = pubsub.topic "my-topic"

  topic.publish "A Message"
end
# [END publish_message]

# [START pull_messages]
def pull_messages
  gcloud = Gcloud.new "my-gcp-project-id"
  pubsub = gcloud.pubsub
  subscription = pubsub.subscription "my-subscription"

  puts "Messages pulled:"
  subscription.pull.each do |message|
    puts message.data
    message.acknowledge!
  end
end
# [END pull_messages]

# [START list_topics]
def list_topics
  gcloud = Gcloud.new "my-gcp-project-id"
  pubsub = gcloud.pubsub
  topics = pubsub.topics

  puts "Topics:"
  topics.each do |topic|
    puts topic.name
  end
end
# [END list_topics]

# [START list_subscriptions]
def list_subscriptions
  gcloud = Gcloud.new "my-gcp-project-id"
  pubsub = gcloud.pubsub
  subscriptions = pubsub.subscriptions

  puts "Subscriptions:"
  subscriptions.each do |subscription|
    puts subscription.name
  end
end
# [END list_subscriptions]
