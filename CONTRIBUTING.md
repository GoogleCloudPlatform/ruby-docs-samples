# How to become a contributor and submit your own code

## Contributor License Agreements

We'd love to accept your sample apps and patches! Before we can take them, we
have to jump a couple of legal hurdles.

Please fill out either the individual or corporate Contributor License Agreement
(CLA).

  * If you are an individual writing original source code and you're sure you
    own the intellectual property, then you'll need to sign an [individual CLA]
    (https://developers.google.com/open-source/cla/individual).
  * If you work for a company that wants to allow you to contribute your work,
    then you'll need to sign a [corporate CLA]
    (https://developers.google.com/open-source/cla/corporate).

Follow either of the two links above to access the appropriate CLA and
instructions for how to sign and return it. Once we receive it, we'll be able to
accept your pull requests.

## Contributing A Patch

1. Submit an issue describing your proposed change to the repo in question.
1. The repo owner will respond to your issue promptly.
1. If your proposed change is accepted, and you haven't already done so, sign a
   Contributor License Agreement (see details above).
1. Fork the desired repo, develop and test your code changes.
1. Ensure that your code adheres to the existing style in the sample to which
   you are contributing.
1. Ensure that your code has an appropriate set of unit tests which all pass.
1. Submit a pull request.

## Code snippets

This repository contains various code snippets that are embedded into
product documentation web pages.

The preferred template for a snippet:

```ruby
# storage/buckets.rb

def create_bucket project_id:, bucket_name:
  # [START create_bucket]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Your Google Cloud Storage bucket name"
  
  require "google/cloud/storage"
  
  storage = Google::Cloud::Storage.new project_id
  
  bucket = storage.create_bucket bucket_name
  
  puts "Created bucket #{bucket.name}"
  # [END create_bucket]
end
```

#### Region tags

The `[START create_bucket]` and `[END create_bucket]` annotations are
examples of documentation "region tags."  These are used throughout
this repository for defining blocks of code to be embedded into
documentation web pages.

#### Placeholder variables

When a code snippet makes use of variables that are defined outside
of the snippet, add commented-out variable declarations to the top
of the snippet.

This allows developers to copy/paste the snippet in its entirety
into their own file and run it by simply setting these variables
with their own values.

#### require statements

Reference code snippets that demonstrate how to perform a
task in isolation should include:

 - all necessary `require` statements that are useful to document
 - instantiation of a client library

By including this in every snippet, readers can copy/paste this snippet
without having to research how to create the client.

A notable exception to this is for Tutorial applications.

#### Tutorial application snippets

Tutorials document the steps to create a fully working application.
In a tutorial, the first code snippet on the page typically demonstrates
how to instantiate a client library, including requiring the necessary
dependency.  Other snippets that show code blocks from the working application
do not need to demonstrate how to instantiate a client.  For example:

##### Pub/Sub sample application

Create client:

```ruby
require "google/cloud/pubsub"

@pubsub = Google::Cloud::Pubsub.new
```

Send notification by publishing to topic:

```ruby
def send_notification message
  topic = @pubsub.topic "notifications"

  topic.publish message
end
```

The client can pull notifications by pulling from subscription:

```ruby
def get_latest_notifications
  subscription  = @pubsub.subscription "mobile-notifications"
  messages      = subscription.pull
  notifications = messages.map { |msg| Notifiction.new msg.data }
  
  notifications
end
```

By using an instance variable for the `@pubsub` client, additional
snippets can access the client in a self-explanatory way.

## Style

Samples in this repository follow the
[GitHub Ruby Styleguide](https://github.com/styleguide/ruby)
except where noted otherwise.

#### Variable alignment

Align variables to improve the readability of embedded code snippets.

```ruby
# good
storage_client = Google::Cloud::Storage.new
bucket         = storage.create_bucket "my-bucket"
uploaded_file  = bucket.file "my-file.txt"

# bad
storage_client = Google::Cloud::Storage.new
bucket = storage.create_bucket "my-bucket"
uploaded_file = bucket.file "my-file.txt"
```
