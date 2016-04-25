# Ruby Twilio voice and SMS sample for Google App Engine flexible environment

This sample demonstrates how to use [Twilio](https://www.twilio.com) on
[Google App Engine flexible environment](https://cloud.google.com/appengine/docs/flexible/).

For more information about Twilio, see their [Ruby quickstart tutorials](https://www.twilio.com/docs/quickstart/ruby).

## Setup

Before you can run or deploy the sample, you will need to do the following:

1. [Create a Twilio Account](http://ahoy.twilio.com/googlecloudplatform). Google App Engine
customers receive a complimentary credit for SMS messages and inbound messages.

2. Create a number on twilio, and configure the voice request URL to be ``https://your-app-id.appspot.com/call/receive``
and the SMS request URL to be ``https://your-app-id.appspot.com/sms/receive``.

3. Configure your Twilio settings in the environment variables section in ``app.yaml``.

## Running locally

Refer to the [appengine/README.md](../README.md) file for instructions on
running and deploying.

You can run the application locally to test the callbacks and SMS sending. You
will need to set environment variables before starting your application:

    $ export TWILIO_ACCOUNT_SID=[your-twilio-accoun-sid]
    $ export TWILIO_AUTH_TOKEN=[your-twilio-auth-token]
    $ export TWILIO_NUMBER=[your-twilio-number]
    $ bundle install
    $ bundle exec ruby app.rb
