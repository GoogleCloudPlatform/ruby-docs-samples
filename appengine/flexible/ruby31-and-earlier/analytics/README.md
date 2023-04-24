# Google Analytics Measurement Protocol on Google App Engine flexible environment

This sample demonstrates how to use the
[Google Analytics Measurement Protocol](https://developers.google.com/analytics/devguides/collection/protocol/v1/)
on [Google App Engine flexible environment](https://cloud.google.com/appengine/docs/flexible/).

## Setup

Before you can run or deploy the sample, you need to do the following:

1. Create a Google Analytics Property and obtain the Tracking ID.
1. Update the environment variables in `app.yaml` with your Tracking ID.

## Running locally

Refer to the [appengine/README.md](../README.md) file for instructions on
running and deploying.

To run locally, set the environment variables via your shell before running the
sample:

    export GA_TRACKING_ID=<your-tracking-id>
    bundle install
    bundle exec ruby app.rb
