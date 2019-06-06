# App Engine Standard Environment - Configs sample

# Configuring a Ruby app for Google App Engine

This sample demonstrates basic configuration options for Ruby apps running on
the [Google App Engine standard environment](https://cloud.google.com/appengine).

## Running locally

Refer to the [appengine/README.md](../../README.md) file for instructions on
running and deploying.

## Configurations demonstrated

The app currently includes an example app.yaml. Additional configuration files
may be added in the future.

The app.yaml demonstrates:

* Using the `entrypoint` field to specify puma as the entrypoint.
* Setting the `instance_class` to give the Ruby app additional resources.
* Using `env_variables` to set environment variables, including the app
  environment
* Setting custom `handlers` to serve static files without invoking ruby.
