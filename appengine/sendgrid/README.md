# Ruby SendGrid email sample for Google App Engine flexible environment

This sample demonstrates how to use [SendGrid](https://www.sendgrid.com) on
[Google App Engine flexible environment](https://cloud.google.com/appengine/docs/flexible/).

For more information about SendGrid, see their
[documentation](https://sendgrid.com/docs/User_Guide/index.html).

## Setup

Before you can run or deploy the sample, you will need to do the following:

1. [Create a SendGrid Account](https://sendgrid.com/free). As of
April 2016, SendGrid provides free accounts that can send 12,000 emails a
month with full-feature access
1. Configure your SendGrid settings in the environment variables section in
`app.yaml`.

## Running locally

Refer to the [appengine/README.md](../README.md) file for instructions on
running and deploying.

You can run the application locally and send emails from your local machine. You
will need to set environment variables before starting your application:

    export SENDGRID_API_KEY=<your-sendgrid-api-key>
    export SENDGRID_SENDER=<your-sendgrid-sender-email-address>
    bundle install
    bundle exec ruby app.rb
