## Table of contents

 - [How to become a contributor and submit your own code](#how-to-become-a-contributor-and-submit-your-own-code)
   - [Contributor License Agreements](#contributor-license-agreements)
   - [Contributing A Patch](#contributing-a-patch)
 - [Style Guide](#style-guide)
   - [Variable alignment](#variable-alignment)
 - [Code samples](#code-samples)
   - [Snippets](#snippets)
     - [Region tags](#region-tags)
   - [Reference snippets](#reference-snippets)
     - [Placeholder values](#placeholder-values)
     - [require statements](#require-statements)
   - [Executing snippets](#executing-snippets)
     - [Argument parsing](#argument-parsing)
   - [Tutorial applications](#tutorial-applications)

## How to become a contributor and submit your own code

### Contributor License Agreements

We'd love to accept your sample apps and patches! Before we can take them, we
have to jump a couple of legal hurdles.

Please fill out either the individual or corporate Contributor License Agreement
(CLA).

  * If you are an individual writing original source code and you're sure you
    own the intellectual property, then you'll need to sign an
    [individual CLA](https://developers.google.com/open-source/cla/individual).
  * If you work for a company that wants to allow you to contribute your work,
    then you'll need to sign a
    [corporate CLA](https://developers.google.com/open-source/cla/corporate).

Follow either of the two links above to access the appropriate CLA and
instructions for how to sign and return it. Once we receive it, we'll be able to
accept your pull requests.

### Setting Up An Environment
For instructions regarding development environment setup, please visit [the documentation](https://cloud.google.com/ruby/docs/setup).

### Contributing A Patch

1. Submit an issue describing your proposed change to the repo in question.
1. The repo owner will respond to your issue promptly.
1. If your proposed change is accepted, and you haven't already done so, sign a
   Contributor License Agreement (see details above).
1. Fork the desired repo, develop and test your code changes.
1. Ensure that your code adheres to the existing style in the sample to which
   you are contributing and that running `bundle exec rubocop` from the root
   directory passes. Running `bundle exec rubocop -a` will attempt to autofix
   all style issues. Use with caution as it may break things.
1. Ensure that your code has an appropriate set of unit tests which all pass.
1. Submit a pull request.

## Style Guide

The [Google Cloud Samples Style Guide][style-guide] is considered the primary
guidelines for all Google Cloud samples. This section details some additional,
Ruby-specific rules that will be merged into the Samples Style Guide in the near
future.

[style-guide]: https://googlecloudplatform.github.io/samples-style-guide/

Samples in this repository also follow the
[GitHub Ruby Styleguide](https://github.com/styleguide/ruby)
except where noted otherwise.

### Variable alignment

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

## Code samples

This repository holds the samples used in the Ruby documentation on
[cloud.google.com](https://cloud.google.com).

There are two distinctly different types of samples:

 1. [Reference snippets](#reference-snippets)
 2. [Tutorial applications](#tutorial-applications)

**Reference snippets** are isolated snippets that demonstrate how to
perform a specific task such as creating a Google Cloud Storage bucket.

**Tutorial applications** are sample applications that demonstrate how to
use one or more Google APIs and products to create a fully-functioning
application.

Specific blocks of code that are embedded in documentation
are defined using `[START snippet_name]` and `[END snippet_name]`
**region tags**.

Example:

```ruby
def create_bucket project_id:, bucket_name:
  # [START create_bucket]
  # project_id  = "Your Google Cloud project ID"
  # bucket_name = "Your Google Cloud Storage bucket name"

  require "google/cloud/storage"

  storage = Google::Cloud::Storage.new project: project_id

  bucket = storage.create_bucket bucket_name

  puts "Created bucket #{bucket.name}"
  # [END create_bucket]
end
```

### Reference snippets

Reference snippets are isolated snippets that demonstrate how to
perform a specific task such as creating a Google Cloud Storage bucket.

Ideally, developers should be able to **copy/paste** the code in a reference
snippet and run it after replacing placeholder values.

#### Placeholder values

When a code snippet makes use of variables that are defined outside
of the snippet, add commented-out variable declarations to the top
of the snippet.

Example:

```ruby
# project_id  = "Your Google Cloud project ID"
# bucket_name = "Your Google Cloud Storage bucket name"

require "google/cloud/storage"

storage = Google::Cloud::Storage.new project: project_id
```

#### require statements

Reference snippets should include the `require` statement(s) necessary
to import relevant dependencies for the code sample.

If a snippet uses a Google Cloud client library, it should be required
in the snippet.  This documents how to require the client library.

Example:

```ruby
# project_id  = "Your Google Cloud project ID"
# bucket_name = "Your Google Cloud Storage bucket name"

require "google/cloud/storage"

storage = Google::Cloud::Storage.new project: project_id
```

**Note:** common libraries such as "date" and "time" do not need to be
required within the snippet.  Explicitly require dependencies that
add value and should be documentated.

### Executing snippets

When possible, reference code snippets should be executable.

Each reference code snippet should be executable via a
corresponding command-line application.

For example, the "create_bucket" snippet in "buckets.rb" should be
executable by running `bundle exec ruby buckets.rb create`

#### Argument parsing

To make snippets executable, add a postable to the end of the file
that calls the snippet's method.

For example:

```ruby
def create_bucket project_id:, bucket_name:
  # ...
end

if $PROGRAM_NAME == __FILE__
  command = ARGV.shift

  case command
  when "create"
    create_bucket project_id:  ENV["GOOGLE_CLOUD_PROJECT"],
                  bucket_name: ARGV.first
  else
    puts <<~USAGE
      Usage: bundle exec ruby buckets.rb [command] [arguments]

      Commands:
      create <bucket>    Create a new bucket with the provided name

      Environment variables:
      GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    USAGE
  end
end
```

Argument parsing is intentionally simple.

### Tutorial applications

Tutorial applications are sample applications that demonstrate how to
use one or more Google APIs and products to create a fully-functioning
application.

A tutorial sample may include command-line application(s) or
web application(s).

For example, the web applications in the [`appengine`](appengine/)
directory are used by short [tutorials](https://cloud.google.com/appengine/docs/flexible/ruby/how-to).

The purpose of tutorial applications is very different from reference snippets.

A tutorial application should be an idiomatic Ruby application.
Code snippets from tutorial applications demonstrate just a *part* of the
*whole* application and are **not isolated**.

 1. Tutorial snippet may not include `require` statements
 1. Tutorial snippet may not include client library instantiation
 1. Tutorial snippet may not include placeholder variables

Here is an small example of the snippets that might be extracted from
a fully implemented tutorial application:

#### Pub/Sub sample application

##### Create client

```ruby
require "google/cloud/pubsub"

@pubsub = Google::Cloud::Pubsub.new
```

##### Send notification by publishing to topic

```ruby
def send_notification message
  topic = @pubsub.topic "notifications"

  topic.publish message
end
```

##### The client can pull notifications by pulling from subscription

```ruby
def get_latest_notifications
  subscription  = @pubsub.subscription "mobile-notifications"
  messages      = subscription.pull
  notifications = messages.map { |msg| Notifiction.new msg.data }

  notifications
end
```
