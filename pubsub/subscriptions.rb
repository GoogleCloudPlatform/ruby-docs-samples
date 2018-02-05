require "google/cloud/pubsub"

def update_push_configuration project_id, subscription_name, new_endpoint
  # [START update_push_configuration]
  # project_id: Your Google Cloud Project ID
  # subscription_name: Your Pubsub subscription name
  # new_endpoint: Endpoint where your app receives messages
  pubsub = Google::Cloud::Pubsub.new project: project_id

  subscription = pubsub.subscription subscription_name
  subscription.endpoint= new_endpoint
  puts "Push endpoint updated."
  # [END update_push_configuration]
end

def list_subscriptions project_id
  # [START list_subscriptions]
  # project_id: Your Google Cloud Project ID
  pubsub = Google::Cloud::Pubsub.new project: project_id

  subscriptions = pubsub.list_subscriptions
  puts "Subscriptions:"
  subscriptions.each do |subscription|
    puts subscription.name
  end
  # [END list_subscriptions]
end

def delete_subscription project_id, subscription_name
  # [START delete_subscription]
  # project_id: Your Google Cloud Project ID
  # subscription_name: Your Pubsub subscription name
  pubsub = Google::Cloud::Pubsub.new project: project_id

  subscription = pubsub.subscription subscription_name
  subscription.delete
  puts "Subscription #{subscription_name} deleted."
  # [END delete_subscription]
end

def get_subscription_policy project_id, subscription_name
  # [START get_subscription_policy]
  # project_id: Your Google Cloud Project ID
  # subscription_name: Your Pubsub subscription name
  # See https://cloud.google.com/pubsub/docs/access_control for more information.
  pubsub = Google::Cloud::Pubsub.new project: project_id

  subscription = pubsub.subscription subscription_name
  policy = subscription.policy
  puts "Subscription policy:"
  puts policy.roles
  # [END get_subscription_policy]
end

def set_subscription_policy project_id, subscription_name
  # [START set_subscription_policy]
  # project_id: Your Google Cloud Project ID
  # subscription_name: Your Pubsub subscription name
  # See https://cloud.google.com/pubsub/docs/access_control for more information.
  pubsub = Google::Cloud::Pubsub.new project: project_id

  subscription = pubsub.subscription subscription_name
  subscription.policy do |policy|
    policy.add "roles/pubsub.subscriber",
      "serviceAccount:account-name@project-name.iam.gserviceaccount.com"
  end
  # [END set_subscription_policy]
end

def test_subscription_permissions project_id, subscription_name
  # [START test_subscription_permissions]
  # project_id: Your Google Cloud Project ID
  # subscription_name: Your Pubsub subscription name
  # See https://cloud.google.com/pubsub/docs/access_control for more information.
  pubsub = Google::Cloud::Pubsub.new project: project_id

  subscription = pubsub.subscription subscription_name
  permissions = subscription.test_permissions "pubsub.subscriptions.consume",
    "pubsub.subscriptions.update"
  puts permissions.include? "pubsub.subscriptions.consume"
  puts permissions.include? "pubsub.subscriptions.update"
  # [END test_subscription_permissions]
end

def listen_for_messages project_id, subscription_name
  # [START listen_for_messages]
  # project_id: Your Google Cloud Project ID
  # subscription_name: Your Pubsub subscription name
  # This method listens for messages in the background. Use pull_messages to
  # pull messages synchronously.
  pubsub = Google::Cloud::Pubsub.new project: project_id

  subscription = pubsub.subscription subscription_name
  subscriber = subscription.listen do |received_message|
    puts "Received message: #{received_message.data}"
    received_message.acknowledge!
  end
  subscriber.start
  # Let the main thread sleep for 60 seconds so the thread for listening
  # messages does not quit
  sleep 60
  subscriber.stop.wait!
end 

def pull_messages project_id, subscription_name
  # [START pull_messages]
  # project_id: Your Google Cloud Project ID
  # subscription_name: Your Pubsub subscription name
  pubsub = Google::Cloud::Pubsub.new project: project_id

  subscription = pubsub.subscription subscription_name
  subscription.pull.each do |message|
    puts "Message pulled: #{message.data}"
    message.acknowledge!
  end
end

def listen_for_messages_with_error_handler project_id, subscription_name
  # [START listen_for_messages_with_error_handler]
  # project_id: Your Google Cloud Project ID
  # subscription_name: Your Pubsub subscription name
  # This method listens for messages in the background and will raise an
  # exception when something goes wrong. Note that exceptions from callback
  # functions are handled within the callback thread pool; they will not reach
  # the main thread
  pubsub = Google::Cloud::Pubsub.new project: project_id

  subscription = pubsub.subscription subscription_name
  subscriber = subscription.listen do |received_message|
    puts "Received message: #{received_message.data}"
    received_message.acknowledge!
  end
  # Propagate expection from child threads to the main thread as soon as it is
  # raised
  Thread.abort_on_exception= true
  begin
    subscriber.start
    # Let the main thread sleep for 60 seconds so the thread for listening
    # messages does not quit
    sleep 60
    subscriber.stop.wait!
  rescue Exception => ex
    puts "Exception #{ex.inspect}: #{ex.message}"
    raise "Stopped listening for messages."
  end
end

def listen_for_messages_with_flow_control project_id, subscription_name
  # [START listen_for_messages_with_flow_control]
  # project_id: Your Google Cloud Project ID
  # subscription_name: Your Pubsub subscription name
  # This method listens for messages in the background with the subscriber
  # collects (at most) 10 messages every time 
  pubsub = Google::Cloud::Pubsub.new project: project_id

  subscription = pubsub.subscription subscription_name
  subscriber = subscription.listen inventory: 10 do |received_message|
    puts "Received message: #{received_message.data}"
    received_message.acknowledge!
  end
  subscriber.start
  # Let the main thread sleep for 60 seconds so the thread for listening
  # messages does not quit
  sleep 60
  subscriber.stop.wait!
end

def listen_for_messages_with_concurrency_control project_id, subscription_name
  # [START listen_for_messages_with_concurrency_control]
  # project_id: Your Google Cloud Project ID
  # subscription_name: Your Pubsub subscription name
  # This method listens for messages in the background with limited number of
  # threads
  pubsub = Google::Cloud::Pubsub.new project: project_id

  subscription = pubsub.subscription subscription_name
  # Use 2 threads for streaming, 4 threads for executing callbacks and 2 threads
  # for sending acknowledgements and/or delays
  subscriber = subscription.listen streams: 2, threads: {
    :callback => 4,
    :push => 2
  } do |received_message |
    puts "Received message: #{received_message.data}"
    received_message.acknowledge!
  end
  subscriber.start
  # Let the main thread sleep for 60 seconds so the thread for listening
  # messages does not quit
  sleep 60
  subscriber.stop.wait!
end

if __FILE__ == $0
  case ARGV.shift
  when "update_push_configuration"
    update_push_configuration project_id: ARGV.shift, 
      subscription_name: ARGV.shift,
      new_endpoint: ARGV.shift
  when "list_subscriptions"
    list_subscriptions project_id: ARGV.shift
  when "delete_subscription"
    delete_subscription project_id: ARGV.shift, 
      subscription_name: ARGV.shift
  when "get_subscription_policy"
    get_subscription_policy project_id: ARGV.shift, 
      subscription_name: ARGV.shift
  when "set_subscription_policy"
    set_subscription_policy project_id: ARGV.shift,
      subscription_name: ARGV.shift
  when "test_subscription_permissions"
    test_subscription_permissions project_id: ARGV.shift,
      subscription_name: ARGV.shift
  when "listen_for_messages"
    listen_for_messages project_id: ARGV.shift, 
      subscription_name: ARGV.shift
  when "pull_messages"
    pull_messages project_id: ARGV.shift, subscription_name: ARGV.shift
  when "listen_for_messages_with_error_handler"
    listen_for_messages_with_error_handler project_id: ARGV.shift,
      subscription_name: ARGV.shift
  when "listen_for_messages_with_flow_control"
    listen_for_messages_with_flow_control project_id: ARGV.shift,
      subscription_name: ARGV.shift
  when "listen_for_messages_with_concurrency_control"
    listen_for_messages_with_concurrency_control project_id: ARGV.shift,
      subscription_name: ARGV.shift
  else
    puts <<~usage
Usage: bundle exec ruby subscriptions.rb [command] [arguments]

Commands and Arguments:
  update_push_configuration [project_id] [subscription_name] [endpoint]
  list_subscriptions [project_id]
  delete_subscription [project_id] [subscription_name]
  get_subscription_policy [project_id] [subscription_name]
  set_subscription_policy [project_id] [subscription_name]
  test_subscription_policy [project_id] [subscription_name]
  listen_for_messages [project_id] [subscription_name]
  pull_messages [project_id] [subscription_name]
  listen_for_messages_with_error_handler [project_id] [subscription_name]
  listen_for_messages_with_flow_control [project_id] [subscription_name]
  listen_for_messages_with_concurrency_control [project_id] [subscription_name]
    usage
  end
end






